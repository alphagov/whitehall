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
          api.publish_async(html_attachment)
        end
        content_ids_to_remove.each do |content_id|
          api.publish_redirect_async(
            content_id,
            Whitehall.url_maker.public_document_path(edition)
          )
        end
      end
      alias :force_publish :publish

      def update_draft
        current_html_attachments.each do |html_attachment|
          api.save_draft_async(html_attachment)
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
          api.publish_redirect_async(html_attachment.content_id, destination)
        end
      end

      def withdraw
        current_html_attachments.each do |html_attachment|
          api.publish_withdrawal_async(
            html_attachment.content_id,
            edition.unpublishing.explanation,
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

      def api
        Whitehall::PublishingApi
      end
    end
  end
end
