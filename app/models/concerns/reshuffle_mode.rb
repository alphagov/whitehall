module ReshuffleMode
  extend ActiveSupport::Concern

  included do
    def republish_ministerial_pages_to_publishing_api
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksPresenter", update_live?)
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::MinistersIndexPresenter", update_live?)
    end

    def republish_ministers_index_page_to_publishing_api
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::MinistersIndexPresenter", update_live?)
    end

    def republish_how_government_works_page_to_publishing_api
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksPresenter", update_live?)
    end

    def reshuffle_in_progress?
      SitewideSetting.find_by(key: :minister_reshuffle_mode)&.on || false
    end
  end

  def update_live?
    !reshuffle_in_progress?
  end
end
