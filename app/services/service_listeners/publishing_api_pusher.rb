module ServiceListeners
  class PublishingApiPusher
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def push(event:, options: {})
      # This is done synchronously before the rest of the publishing,
      # because it creates redirects and currently (02/11/2016) publishing-api links
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

    # If the previous edition had extra translations, redirect them to the :en locale.
    # Unmigrated formats as of now (02/11/2016) do not work with this, as the redirects
    # are not removed if the translation is added back in.
    def handle_translations
      is_migrated_format = edition.rendering_app != Whitehall::RenderingApp::WHITEHALL_FRONTEND
      if is_migrated_format
        previous_edition = edition.previous_edition
        if previous_edition
          removed_locales = previous_edition.translations.map(&:locale) - edition.translations.map(&:locale)
          removed_locales.each do |locale|
            PublishingApiRedirectWorker.new.perform(
              edition.content_id,
              edition.search_link,
              locale
            )
          end
        end
      end
    end

    def api
      Whitehall::PublishingApi
    end
  end
end
