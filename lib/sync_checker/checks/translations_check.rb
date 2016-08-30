module SyncChecker
  module Checks
    TranslationsCheck = Struct.new(:expected_locales) do
      attr_reader :content_item
      def call(response)
        stringified_locales = expected_locales.map(&:to_s)
        failures = []
        if response.response_code == 200
          @content_item = JSON.parse(response.body)
          available_translations = content_item["links"]["available_translations"]
          if run_check?
            if available_translations
              locales_present = available_translations.map { |translation| translation["locale"] }
              if locales_present != stringified_locales
                failures << "expected #{stringified_locales} translations but got #{locales_present}"
              end
            else
              failures << "available_translations element not present"
            end
          end
        end
        failures
      end

    private

      def run_check?
        %w(redirect gone).exclude?(content_item["schema_name"])
      end
    end
  end
end
