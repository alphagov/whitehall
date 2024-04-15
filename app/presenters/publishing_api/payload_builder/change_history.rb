module PublishingApi
  module PayloadBuilder
    class ChangeHistory
      def self.for(document)
        new(document).call
      end

      def initialize(document)
        self.document = document
      end

      def call
        return {} if document.change_history.blank?

        { change_history: document.change_history.as_json }
      end

    private

      attr_accessor :document
    end
  end
end
