module ServiceListeners
  class PublishingApiPusher
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def push(event:, options: {})
      case event
      when "force_publish", "publish"
        unpublish_removed_translations
        api.publish(edition)
      when "update_draft"
        api.patch_links(edition)
        api.save_draft(edition)
      when "update_draft_translation"
        api.patch_links(edition)
        api.save_draft_translation(edition, options.fetch(:locale))
      when "unpublish"
        api.unpublish_sync(edition.unpublishing)
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

      handle_associated_documents(event)
    end

  private

    def handle_associated_documents(event)
      if edition.respond_to?(:associated_documents) || edition.respond_to?(:deleted_associated_documents)
        PublishingApiAssociatedDocuments.process(edition, event)
      end
    end

    def unpublish_removed_translations
      previous_edition = edition.previous_edition

      if previous_edition
        edition_url = edition.public_url
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
