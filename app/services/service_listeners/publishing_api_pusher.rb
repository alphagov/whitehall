module ServiceListeners
  class PublishingApiPusher
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def push(event:, options: {})
      case event
      when "force_publish", "publish"
        api.publish_async(edition)
      when "update_draft"
        api.save_draft_async(edition)
      when "update_draft_translation"
        api.save_draft_translation_async(edition, options.fetch(:locale))
      when "unpublish"
        api.unpublish_async(edition.unpublishing)
      when "withdraw"
        api.publish_withdrawal_async(
          edition.content_id,
          edition.unpublishing.explanation,
          edition.primary_locale
        )
      when "force_schedule", "schedule"
        api.schedule_async(edition)
      when "unschedule"
        api.unschedule_async(edition)
      when "delete"
        api.discard_draft_async(edition)
      end

      html_attachments_pusher(event).call
    end

  private

    def html_attachments_pusher(event)
      Whitehall::PublishingApi::HtmlAttachmentPusher.new(
        edition: edition,
        event: event
      )
    end

    def api
      Whitehall::PublishingApi
    end
  end
end
