require 'whitehall/publishing_api'

module Whitehall
  class PublishingApi
    class HtmlAttachmentPusher
      attr_reader :edition, :event
      def initialize(edition:, event:)
        @edition = edition
        @event = event
      end

      def call
        send(event) if respond_to?(event) && edition.respond_to?(:html_attachments)
      end

      def publish
        current_html_attachments.each do |html_attachment|
          PublishingApiWorker.new.perform(
            html_attachment.class.name,
            html_attachment.id,
            edition.minor_change? ? "minor" : "major",
            html_attachment.locale || I18n.default_locale.to_s
          )
        end
        content_ids_to_remove.each do |content_id|
          PublishingApiRedirectWorker.new.perform(
            content_id,
            Whitehall.url_maker.public_document_path(edition),
            I18n.default_locale.to_s
          )
        end
      end
      alias :force_publish :publish

      def update_draft
        current_html_attachments.each do |html_attachment|
          PublishingApiDraftWorker.new.perform(
            html_attachment.class.name,
            html_attachment.id,
            edition.minor_change? ? "minor" : "major",
            html_attachment.locale || I18n.default_locale.to_s
          )
        end
      end
      # we don't care whether this is a translation or the main document, we just send the
      # correct html attachments regardless.
      alias :update_draft_translation :update_draft

      def unpublish
        unpublishing = edition.unpublishing
        return if unpublishing.nil?

        destination = if unpublishing.redirect?
                        Addressable::URI.parse(unpublishing.alternative_url).path
                      else
                        Whitehall.url_maker.public_document_path(edition)
                      end

        current_html_attachments.each do |html_attachment|
          PublishingApiRedirectWorker.new.perform(
            html_attachment.content_id,
            destination,
            html_attachment.locale || I18n.default_locale.to_s
          )
        end
      end

      def withdraw
        current_html_attachments.each do |html_attachment|
          PublishingApiWithdrawalWorker.new.perform(
            html_attachment.content_id,
            edition.unpublishing.explanation,
            edition.primary_locale
          )
        end
      end

      def delete
        current_html_attachments.each do |html_attachment|
          PublishingApiDiscardDraftWorker.perform_async(
            html_attachment.content_id,
            edition.primary_locale
          )
        end
      end

    private

      def previous_edition
        @previous_edition ||= edition.previous_edition
      end

      def current_html_attachments
        edition.html_attachments
      end

      def content_ids_to_remove
        return Set[] unless previous_edition
        old_content_ids = previous_edition.html_attachments.pluck(:content_id).to_set
        new_content_ids = current_html_attachments.pluck(:content_id).to_set

        old_content_ids - new_content_ids
      end
    end
  end
end
