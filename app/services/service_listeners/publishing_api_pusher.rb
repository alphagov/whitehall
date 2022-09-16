module ServiceListeners
  class PublishingApiPusher
    include LockedDocumentConcern

    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def push(event:, options: {})
      check_if_locked_document(edition:)

      # This is done synchronously before the rest of the publishing.
      # Currently (02/11/2016) publishing-api links
      # are not recalculated on parent documents when their translations are unpublished.
      handle_translations

      case event
      when "force_publish", "publish"
        api.publish(edition)
      when "update_draft"
        api.patch_links(edition)
        api.save_draft(edition)
      when "update_draft_translation"
        api.patch_links(edition)
        api.save_draft_translation(edition, options.fetch(:locale))
      when "unpublish"
        api.unpublish_async(edition.unpublishing)
      when "withdraw"
        edition.translations.each do |translation|
          api.publish_withdrawal_async(
            edition.content_id,
            edition.unpublishing.explanation,
            edition.unpublishing.unpublished_at,
            translation.locale.to_s,
          )
        end
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
      if edition.respond_to?(:html_attachments)
        PublishingApiHtmlAttachments.process(edition, event)
      end
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
            locale,
          )
        end
      end
    end

    def api
      Whitehall::PublishingApi
    end
  end
end
