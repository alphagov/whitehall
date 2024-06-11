module ReshuffleMode
  extend ActiveSupport::Concern

  included do
    def republish_ministerial_pages_to_publishing_api
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksPresenter")
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::MinistersIndexPresenter")
    end
  end
end
