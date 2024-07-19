module ServiceListeners
  class PublishingApiAssociatedDocuments
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
      if Edition::PRE_PUBLICATION_STATES.include?(edition.state)
        update_draft(update_type: "republish")
      elsif edition.unpublishing && edition.withdrawn?
        do_publish("republish")
        discard_drafts(deleted_associated_documents)
        withdraw
      elsif edition.unpublishing
        update_draft(update_type: "republish")
        patch_links
        unpublish(allow_draft: true)
      else
        do_publish("republish")
        discard_drafts(deleted_associated_documents)
      end
    end

    def update_draft(update_type: nil)
      current_associated_documents.each do |associated_document|
        Whitehall::PublishingApi.save_draft(
          associated_document,
          update_type || (edition.minor_change? ? "minor" : "major"),
        )
      end
      discard_drafts(deleted_associated_documents)
    end
    # We don't care whether this is a translation or the main
    # document, we just send the correct html attachments regardless.
    alias_method :update_draft_translation, :update_draft

    def unpublish(allow_draft: false)
      destination = if edition.unpublishing.redirect?
                      edition.unpublishing.alternative_path
                    else
                      edition.public_path
                    end

      current_associated_documents.each do |associated_document|
        if associated_document.respond_to?(:translations)
          associated_document.translations.each do |translation|
            PublishingApiRedirectWorker.new.perform(
              associated_document.content_id,
              destination,
              translation.locale.to_s,
              allow_draft,
            )
          end
        else
          PublishingApiRedirectWorker.new.perform(
            associated_document.content_id,
            destination,
            locale_for_document(associated_document).to_s,
            allow_draft,
          )
        end
      end
    end

    def withdraw
      current_associated_documents.each do |associated_document|
        if associated_document.respond_to?(:translations)
          associated_document.translations.each do |translation|
            PublishingApiWithdrawalWorker.new.perform(
              associated_document.content_id,
              edition.unpublishing.explanation,
              translation.locale.to_s,
              false,
              edition.unpublishing.unpublished_at.to_s,
            )
          end
        else
          PublishingApiWithdrawalWorker.new.perform(
            associated_document.content_id,
            edition.unpublishing.explanation,
            locale_for_document(associated_document).to_s,
            false,
            edition.unpublishing.unpublished_at.to_s,
          )
        end
      end
    end

    def delete
      discard_drafts(current_associated_documents + deleted_associated_documents)
    end

  private

    def locale_for_document(document)
      if document.respond_to?(:locale) && document.locale
        document.locale
      else
        I18n.default_locale.to_s
      end
    end

    def discard_drafts(associated_documents)
      associated_documents.each do |associated_document|
        if associated_document.respond_to?(:translations)
          associated_document.translations.each do |translation|
            PublishingApiDiscardDraftWorker.perform_async(
              associated_document.content_id,
              translation.locale.to_s,
            )
          end
        else
          PublishingApiDiscardDraftWorker.perform_async(
            associated_document.content_id,
            locale_for_document(associated_document).to_s,
          )
        end
      end
    end

    def patch_links
      current_associated_documents.each do |associated_document|
        Whitehall::PublishingApi.patch_links(associated_document, bulk_publishing: false)
      end
    end

    def previous_edition
      @previous_edition ||= edition.previous_edition
    end

    def current_associated_documents
      edition.associated_documents
    end

    def previous_associated_documents
      return [] unless previous_edition

      previous_edition.associated_documents
    end

    def content_ids_to_remove
      return Set[] unless previous_edition

      deleted_content_ids = deleted_associated_documents.map(&:content_id).to_set
      old_content_ids = previous_associated_documents.map(&:content_id).to_set
      new_content_ids = current_associated_documents.map(&:content_id).to_set

      deleted_content_ids + old_content_ids - new_content_ids
    end

    def deleted_associated_documents
      edition.deleted_associated_documents
    end

    def do_publish(update_type)
      edition.translations.each do |translation|
        content_ids_to_remove.each do |content_id|
          PublishingApiRedirectWorker.new.perform(
            content_id,
            edition.public_path,
            translation.locale.to_s,
          )
        end
      end

      current_associated_documents.each do |associated_document|
        if associated_document.respond_to?(:translations)
          associated_document.translations.each do |translation|
            PublishingApiWorker.new.perform(
              associated_document.class.name,
              associated_document.id,
              update_type,
              translation.locale.to_s,
            )
          end
        else
          PublishingApiWorker.new.perform(
            associated_document.class.name,
            associated_document.id,
            update_type,
            locale_for_document(associated_document).to_s,
          )
        end
      end
    end
  end
end
