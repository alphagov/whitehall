class PublishingApiDraftUpdateWorker < WorkerBase
  sidekiq_options queue: "publishing_api"
  def perform(attachable_model_class, attachable_model_id)
    attachable = attachable_model_class.constantize.find(attachable_model_id)
    draft_updater = Whitehall.edition_services.draft_updater(attachable)
    draft_updater.perform!
  end
end
