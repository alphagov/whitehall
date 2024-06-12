class SitewideSetting < ApplicationRecord
  validates :govspeak, presence: true, if: :on
  validates :key, presence: true
  validates :key, uniqueness: { case_sensitive: false } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates_with SafeHtmlValidator

  after_save :republish_downstream_if_reshuffle

  def human_status
    on ? "On" : "Off"
  end

  def name
    key.humanize
  end

  def republish_downstream_if_reshuffle
    return unless key == "minister_reshuffle_mode"

    update_live = true
    if on
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksEnableReshufflePresenter", update_live)
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::MinistersIndexEnableReshufflePresenter", update_live)
    else
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksPresenter", update_live)
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::MinistersIndexPresenter", update_live)
    end
  end
end
