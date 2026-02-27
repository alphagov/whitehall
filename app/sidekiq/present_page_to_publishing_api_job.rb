class PresentPageToPublishingApiJob < JobBase
  def perform(presenter)
    PresentPageToPublishingApi.new.publish(presenter.constantize)
  end
end
