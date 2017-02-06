module ServiceListeners
  class PublishingApiPusher
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def push(event:, options: {})
      # This is done synchronously before the rest of the publishing.
      # Currently (02/11/2016) publishing-api links
      # are not recalculated on parent documents when their translations are unpublished.
      handle_translations

      case event
      when "force_publish", "publish", "unwithdraw"
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

      handle_html_attachments(event)
    end

  private

    def handle_html_attachments(event)
      PublishingApiHtmlAttachmentsWorker.perform_async(edition.id, event)
    end

    def handle_translations
      previous_edition = edition.previous_edition

      if previous_edition
        edition_url = Whitehall::UrlMaker.new.public_document_url(edition)
        removed_locales = previous_edition.translations.map(&:locale) - edition.translations.map(&:locale)
        removed_locales.each do |locale|
          PublishingApiGoneWorker.new.perform(
            edition.content_id,
            "",
            "This translation is no longer available. You can find the original version of this content at [#{edition_url}](#{edition_url})",
            locale
          )
        end
      end
    end

    def api
      Whitehall::PublishingApi
    end
  end
end
