class StandardEditionMigratorJob < JobBase
  # Don't retry this job if it fails, because it's typically all
  # ‘internal’ – so it won’t fail because a third-party API is down,
  # and any failure is unlikely to resolve itself on a retry.
  # The exception is MySQL deadlocks, which we retry per record (see below).
  sidekiq_options queue: "standard_edition_migration", retry: 0

  MAX_DEADLOCK_ATTEMPTS = 3

  # Migrates each record sequentially, rather than enqueuing a job per record,
  # because running many migrations in parallel causes MySQL deadlocks.
  def perform(record_ids, args)
    model_class = args["model_class"].constantize
    recipe = args["recipe_class"].constantize
    migration_method = args["migration_method"]
    raise_if_payloads_differ = args["raise_if_payloads_differ"]

    record_ids.each do |record_id|
      with_deadlock_retries do
        legacy_record = model_class.find(record_id)
        StandardEditionMigrator.send(migration_method, legacy_record, recipe, raise_if_payloads_differ: raise_if_payloads_differ)
      end
    rescue StandardError => e
      # Report and carry on, so that one failing record doesn't block the rest
      logger.error("StandardEditionMigratorJob: failed to migrate #{model_class.name} #{record_id}: #{e.message}")
      GovukError.notify(e, extra: { model_class: model_class.name, record_id: })
    end
  end

private

  def with_deadlock_retries
    attempts = 0
    begin
      attempts += 1
      yield
    rescue ActiveRecord::Deadlocked
      retry if attempts < MAX_DEADLOCK_ATTEMPTS
      raise
    end
  end
end
