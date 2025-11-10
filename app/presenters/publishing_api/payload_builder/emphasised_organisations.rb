module PublishingApi
  module PayloadBuilder
    class EmphasisedOrganisations
      def self.for(document)
        new(document).call
      end

      def initialize(document)
        self.document = document
      end

      def call
        { emphasised_organisations: document.lead_organisations.map(&:content_id) }
      end

    private

      attr_accessor :document
    end
  end
end
