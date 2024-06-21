class PatchLinksPublishingApiWorker < WorkerBase
  def perform(presenter)
    PresentPageToPublishingApi.new.patch_links(presenter.constantize)
  end
end
