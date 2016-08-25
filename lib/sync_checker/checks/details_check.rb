require 'equivalent-xml'

module SyncChecker
  module Checks
    DetailsCheck = Struct.new(:expected_details) do
      attr_reader :content_item
      def call(response)
        failures = []
        if response.response_code == 200
          @content_item = JSON.parse(response.body)
          if run_check?
            unless body_is_equivalent?
              failures << "details body doesn't match"
            end
          end
        end
        failures
      end

    private

      def run_check?
        %w(redirect gone).exclude?(content_item["schema_name"])
      end

      def body_is_equivalent?
        EquivalentXml.equivalent?(
          content_item["details"]["body"],
          expected_details[:body]
        )
      end
    end
  end
end
