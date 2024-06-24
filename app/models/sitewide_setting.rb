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

    ministers_index = PublishingApi::MinistersIndexPresenter.new
    if on
      # These have to be sent synchronously so we can guarantee the order in which they're processed.
      # First, send 'page is currently being updated' message to draft stack
      Services.publishing_api.put_content(
        ministers_index.content_id,
        PublishingApi::MinistersIndexEnableReshufflePresenter.new.content,
      )
      # Then promote what's on draft, to live
      Services.publishing_api.publish(ministers_index.content_id, nil, locale: ministers_index.content[:locale])

      # Then, send normal ministers index payload to draft so that we can use it as a preview
      Services.publishing_api.put_content(ministers_index.content_id, ministers_index.content)
      # We're now done with the ministers index page. There is no 'patch links' step required here
      # as we're only changing body content.
      #
      # Finally, we'll republish the How Government Works page, to remove the number of ministers
      # section. There's no need to maintain separate draft/live versions of this page, so we
      # can just use the normal worker.
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksEnableReshufflePresenter")
    else
      # Whatever is on the draft stack, let's publish to the live stack
      Services.publishing_api.publish(ministers_index.content_id, nil, locale: ministers_index.content[:locale])

      # Republish How Government Works page (needs link patching, putting to draft and promoting
      # to live, so use the worker)
      PresentPageToPublishingApiWorker.perform_async("PublishingApi::HowGovernmentWorksPresenter")
    end
  end
end
