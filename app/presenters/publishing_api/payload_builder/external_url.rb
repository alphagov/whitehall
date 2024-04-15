module PublishingApi
  module PayloadBuilder
    class ExternalUrl
      def self.for(document)
        new(document).call
      end

      def initialize(document)
        self.document = document
      end

      def call
        return {} unless document.external?

        { held_on_another_website_url: document.external_url }
      end

    private

      attr_accessor :document
    end
  end
end
