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
        send(event) if respond_to?(event)
      end

      def publish
        current_html_attachments.each do |html_attachment|
          api.publish_async(html_attachment)
        end
        content_ids_to_remove.each do |content_id|
          api.publish_redirect_async(content_id, edition.search_link)
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
