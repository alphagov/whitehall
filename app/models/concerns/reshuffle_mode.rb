module ReshuffleMode
  extend ActiveSupport::Concern

  included do
    def patch_links_ministers_index_page_to_publishing_api
      PatchLinksPublishingApiWorker.perform_async("PublishingApi::MinistersIndexPresenter")
    end

    def republish_how_government_works_page_to_publishing_api
      if reshuffle_in_progress?
        PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksEnableReshufflePresenter")
      else
        PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksPresenter")
      end
    end

    def reshuffle_in_progress?
      SitewideSetting.find_by(key: :minister_reshuffle_mode)&.on || false
    end
  end
end
