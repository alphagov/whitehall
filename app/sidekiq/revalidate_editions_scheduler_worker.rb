class RevalidateEditionsSchedulerWorker
  include Sidekiq::Job
  sidekiq_options queue: "edition_revalidation", retry: 0

  BATCH_SIZE  = 100
  MAX_BATCHES = 1000 # 1000 × 100 = 100 000 editions/run

  def perform
    scope = Edition.not_validated_since(1.week.ago.strftime("%d/%m/%Y"))
    logger.info("[RevalidateEditionsSchedulerWorker] #{scope.count} editions need revalidating")

    # Pull batches in random order so permanently invalid editions
    # don't prevent us from revalidating 'old' revalidated editions
    scope.order(Arel.sql("RAND()")) # MySQL / MariaDB
         .limit(BATCH_SIZE * MAX_BATCHES)
         .pluck(:id)
         .each_slice(BATCH_SIZE) do |ids|
      RevalidateEditionBatchWorker.perform_async(ids)
    end
  end
end
