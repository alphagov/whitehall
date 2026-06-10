require "diffy"
require "pp"

class StandardEditionMigratorJob < JobBase
  # Don't retry this job if it fails, because it's typically all
  # ‘internal’ – so it won’t fail because a third-party API is down,
  # and any failure is unlikely to resolve itself on a retry.
  sidekiq_options queue: "standard_edition_migration", retry: 0

  def perform(record_id, args)
    model_class_name = args["model_class"]
    recipe_class_name = args["recipe_class"]
    migration_method = args["migration_method"]
    raise_if_payloads_differ = args["raise_if_payloads_differ"]

    legacy_record = model_class_name.constantize.find(record_id)
    recipe = recipe_class_name.constantize

    StandardEditionMigrator.send(migration_method, legacy_record, recipe, raise_if_payloads_differ: raise_if_payloads_differ)
  end
end
