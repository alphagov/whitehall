class RemoveDangerousLinksWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(edition_id)
    # TODO: Implement this method
  end
end
