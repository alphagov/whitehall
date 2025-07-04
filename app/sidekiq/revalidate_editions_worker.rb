class RevalidateEditionsWorker
  include Sidekiq::Job
  FIND_EACH_BATCH_SIZE = 50

  # Don't retry if this fails - it's not mission critical
  sidekiq_options retry: 0

  def perform
    editions = Edition.where.not(state: %w[unpublished superseded deleted])
    logger.info("[revalidate-editions-debug]: Revalidating #{editions.count} editions...")
    # ^ approx 400k at last count

    editions.find_each(batch_size: FIND_EACH_BATCH_SIZE) do |edition|
      RevalidateEditionWorker.perform_async(edition.id)
    end
    logger.info("[link-checking-debug][job_#{jid}]: Done batching up revalidation checks for #{editions.count} editions.")
  end
end
