module PublishingApi
  module PayloadBuilder
    class Documents
      def self.for(document)
        new(document).call
      end

      def initialize(document, renderer: Whitehall::GovspeakRenderer.new)
        self.document = document
        self.renderer = renderer
      end

      def call
        return {} if document.attachments.blank?

        {
          documents:,
          featured_attachments:,
        }
      end

    private

      attr_accessor :document, :renderer

      def documents
        renderer.block_attachments(
          document.attachments,
          document.alternative_format_contact_email,
        )
      end

      def featured_attachments
        document.attachments_ready_for_publishing.map { |a| a.publishing_api_details[:id] }
      end
    end
  end
end
