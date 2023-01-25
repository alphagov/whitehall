module ServiceListeners
  class PublishingApiHtmlAttachments
    attr_reader :edition

    def self.process(edition, event)
      instance = new(edition)
      instance.send(event) if instance.respond_to?(event)
    end

    def initialize(edition)
      @edition = edition
    end

    def publish
      do_publish(edition.minor_change? ? "minor" : "major")
    end
    alias_method :force_publish, :publish
    alias_method :unwithdraw, :publish

    def republish
      update_publishing_api_content
      unpublish_if_required
    end

    def update_draft(update_type: nil)
      current_html_attachments.each do |html_attachment|
        Whitehall::PublishingApi.save_draft_translation(
          html_attachment,
          html_attachment.locale || I18n.default_locale.to_s,
          update_type || (edition.minor_change? ? "minor" : "major"),
        )
      end
      discard_drafts(deleted_html_attachments)
    end

    # We don't care whether this is a translation or the main
    # document, we just send the correct html attachments regardless.
    alias_method :update_draft_translation, :update_draft

    def unpublish(allow_draft: false)
      destination = if edition.unpublishing.redirect?
                      Addressable::URI.parse(edition.unpublishing.alternative_url).path
                    else
                      edition.public_path
                    end

      current_html_attachments.each do |html_attachment|
        PublishingApiRedirectWorker.new.perform(
          html_attachment.content_id,
          destination,
          html_attachment.locale || I18n.default_locale.to_s,
          allow_draft,
        )
      end
    end

    def withdraw
      current_html_attachments.each do |html_attachment|
        PublishingApiWithdrawalWorker.new.perform(
          html_attachment.content_id,
          edition.unpublishing.explanation,
          edition.primary_locale,
          false,
          edition.unpublishing.unpublished_at.to_s,
        )
      end
    end

    def delete
      discard_drafts(current_html_attachments + deleted_html_attachments)
    end

  private

    def discard_drafts(html_attachments)
      html_attachments.each do |html_attachment|
        PublishingApiDiscardDraftWorker.perform_async(
          html_attachment.content_id,
          edition.primary_locale,
        )
      end
    end

    def update_publishing_api_content
      if Edition::PRE_PUBLICATION_STATES.include?(edition.state)
        update_draft(update_type: "republish")
      else
        do_publish("republish")
        discard_drafts(deleted_html_attachments)
      end
    end

    def unpublish_if_required
      if edition.unpublishing
        if edition.withdrawn?
          withdraw
        else
          unpublish(allow_draft: true)
        end
      end
    end

    def previous_edition
      @previous_edition ||= edition.previous_edition
    end

    def current_html_attachments
      edition.attachables.flat_map(&:html_attachments)
    end

    def previous_html_attachments
      return [] unless previous_edition

      previous_edition.attachables.flat_map(&:html_attachments)
    end

    def content_ids_to_remove
      return Set[] unless previous_edition

      deleted_content_ids = deleted_html_attachments.map(&:content_id).to_set
      old_content_ids = previous_html_attachments.map(&:content_id).to_set
      new_content_ids = current_html_attachments.map(&:content_id).to_set

      deleted_content_ids + old_content_ids - new_content_ids
    end

    def deleted_html_attachments
      edition.attachables.flat_map(&:deleted_html_attachments)
    end

    def do_publish(update_type)
      content_ids_to_remove.each do |content_id|
        PublishingApiRedirectWorker.new.perform(
          content_id,
          edition.public_path,
          I18n.default_locale.to_s,
        )
      end

      current_html_attachments.each do |html_attachment|
        PublishingApiWorker.new.perform(
          html_attachment.class.name,
          html_attachment.id,
          update_type,
          html_attachment.locale || I18n.default_locale.to_s,
        )
      end
    end
  end
end
