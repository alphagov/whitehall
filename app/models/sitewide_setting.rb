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
      # These have to be sent synchronously so we can guarantee the order in which they're processed.
      # First, send 'page is currently being updated' message to Draft and promote to Live
      PresentPageToPublishingApiWorker.new.perform("PublishingApi::HowGovernmentWorksEnableReshufflePresenter", update_live)
      PresentPageToPublishingApiWorker.new.perform("PublishingApi::MinistersIndexEnableReshufflePresenter", update_live)
      # Finally, send normal ministers index payload to draft so that we can use it as a preview
      PresentPageToPublishingApiWorker.new.perform("PublishingApi::MinistersIndexPresenter", false)
    else
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksPresenter", update_live)
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::MinistersIndexPresenter", update_live)
    end
  end
end
