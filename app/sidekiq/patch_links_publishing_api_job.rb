class PatchLinksPublishingApiJob < JobBase
  def perform(presenter)
    PresentPageToPublishingApi.new.patch_links(presenter.constantize)
  end
end
