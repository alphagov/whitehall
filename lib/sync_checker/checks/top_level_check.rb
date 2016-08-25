module SyncChecker
  module Checks
    TopLevelCheck = Struct.new(:expected) do
      attr_reader :content_item
      def call(response)
        failures = []
        if response.response_code == 200
          @content_item = JSON.parse(response.body)
          if run_check?
            expected.each do |k, v|
              if expected[k] != content_item[k.to_s]
                failures << "expected #{k}: '#{v}', got '#{content_item[k.to_s]}'"
              end
            end
          end
        end
        failures
      end

    private

      def run_check?
        %w(gone redirect).exclude?(content_item["schema_name"])
      end
    end
  end
end
