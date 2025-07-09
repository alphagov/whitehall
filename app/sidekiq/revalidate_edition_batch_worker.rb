class RevalidateEditionBatchWorker
  include Sidekiq::Job
  sidekiq_options retry: 0, backtrace: false

  def perform(edition_ids)
    Edition.where(id: edition_ids).find_each do |edition|
      edition.valid?(:publish) # revalidates the edition and updates `revalidated_at`
    end
  end
end
