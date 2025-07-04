class RevalidateEditionWorker
  include Sidekiq::Job

  def perform(edition_id)
    edition = Edition.find(edition_id)
    edition.valid?(:publish)
  end
end
