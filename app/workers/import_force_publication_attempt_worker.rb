class ImportForcePublicationAttemptWorker
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  attr_reader :id

  def perform(id)
    @id = id
    force_publish_attempt.perform
  end

private

  def force_publish_attempt
    @force_publish_attempt ||= ForcePublicationAttempt.find(id)
  end
end
