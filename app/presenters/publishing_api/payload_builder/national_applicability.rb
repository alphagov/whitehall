module PublishingApi
  module PayloadBuilder
    class NationalApplicability
      def self.for(document)
        new(document).call
      end

      def initialize(document)
        self.document = document
      end

      def call
        return {} if document.nation_inapplicabilities.blank?

        { national_applicability: document.national_applicability }
      end

    private

      attr_accessor :document
    end
  end
end
