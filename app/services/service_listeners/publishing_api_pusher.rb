module ServiceListeners
  class PublishingApiPusher
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def push(event:, options: {})
      case event
      when "force_publish", "publish"
        perform_publishing_api_action_on_pushable_items(
          action: :publish_async
        )
      when "update_draft"
        perform_publishing_api_action_on_pushable_items(
          action: :save_draft_async
        )
      when "update_draft_translation"
        pushable_items.each do |record|
          api.save_draft_translation_async(record, options.fetch(:locale))
        end
      when "unpublish"
        api.publish_async(edition.unpublishing)
        edition_html_attachments.each do |attachment|
          redirect_if_required(attachment)
        end
      when "withdraw"
        api.republish_document_async(edition.document)
        edition_html_attachments.each do |attachment|
          api.republish_async(attachment)
        end
      when "force_schedule", "schedule"
        api.schedule_async(edition)
        #ignore attachments
      when "unschedule"
        api.unschedule_async(edition)
        #ignore attachments
      when "delete"
        perform_publishing_api_action_on_pushable_items(
          action: :discard_draft_async
        )
      end
    end

  private

    def perform_publishing_api_action_on_pushable_items(action:)
      pushable_items.each do |record|
        api.send(action, record)
      end
    end

    def pushable_items
      pushable_items = [@edition]
      pushable_items + edition_html_attachments
    end

    def edition_html_attachments
      @edition.respond_to?(:html_attachments) ? @edition.html_attachments : []
    end

    def api
      Whitehall::PublishingApi
    end

    def redirect_if_required(attachment)
      if attachment.is_a?(HtmlAttachment)
        if requires_redirect_to_alternative?(attachment)
          redirect_to_unpublishing_alternative(attachment)
        else
          redirect_to_parent(attachment)
        end
      end
    end

    def requires_redirect_to_alternative?(attachment)
      unpublishing = attachment.attachable.unpublishing
      unpublishing.unpublishing_reason_id == UnpublishingReason::Consolidated.id ||
        unpublishing.redirect
    end

    def redirect_to_parent(attachment)
      publish_redirect(
        attachment.content_id,
        Whitehall.url_maker.public_document_path(edition)
      )
    end

    def redirect_to_unpublishing_alternative(attachment)
      edition = attachment.attachable
      publish_redirect(
        attachment.content_id,
        Addressable::URI.parse(
          edition.unpublishing.alternative_url
        ).path
      )
    end

    def publish_redirect(content_id, destination)
      api.publish_redirect_async(content_id, destination)
    end
  end
end
