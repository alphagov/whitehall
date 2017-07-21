module SyncChecker
  module Checks
    TranslationsCheck = Struct.new(:expected_locales) do
      attr_reader :content_item
      def call(response)
        stringified_locales = expected_locales.map(&:to_s)
        failures = []
        if response.response_code == 200
          begin
            @content_item = JSON.parse(response.body)
            #FIXME we're ignore withdrawn items for now due to a bug in
            #publishing api causing them not to have an `available_translations`
            #links element
            return [] if withdrawn?
            available_translations = content_item["links"]["available_translations"]
            if run_check?
              if available_translations
                locales_present = available_translations.map { |translation| translation["locale"] }
                if locales_present.sort != stringified_locales.sort
                  failures << "expected #{stringified_locales} translations but got #{locales_present}"
                end
              else
                failures << "available_translations element not present"
              end
            end
          rescue JSON::ParserErrror
            failures << "response.body not valid JSON. Likely not present in the content store"
          end
        end
        failures
      end

    private

      def run_check?
        %w(redirect gone).exclude?(content_item["schema_name"])
      end

      def withdrawn?
        content_item["withdrawn_notice"].present?
      end
    end
  end
end
