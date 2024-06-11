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
    # should be false when reshuffle mode is on - we'll reuse
    # https://github.com/alphagov/whitehall/blob/685e3ce1687872ed5567bc1d907b822fbd77035e/app/presenters/publishing_api/ministers_index_presenter.rb#L71-L73
    # in a future commit
    true
  end
end
