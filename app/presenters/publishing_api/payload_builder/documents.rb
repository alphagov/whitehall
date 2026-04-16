module PublishingApi
  module PayloadBuilder
    class Documents
      def self.for(document)
        new(document).call
      end

      def initialize(document)
        self.document = document
      end

      def call
        return {} if document.attachments.blank?

        {
          featured_attachments:,
        }
      end

    private

      attr_accessor :document

      def featured_attachments
        document.attachments_ready_for_publishing.map { |a| a.publishing_api_details[:id] }
      end
    end
  end
end
