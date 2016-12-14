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
            expected_details.each do |k, v|
              failures << check_key(k, v)
            end
          end
        end
        failures.compact
      end

    private

      def run_check?
        %w(redirect gone).exclude?(content_item["schema_name"])
      end

      def check_key(key, value)
        return check_body if key.to_s == "body"
        response_value = content_item["details"][key.to_s]
        return "expected details to contain '#{key}' == '#{value}'" if response_value.nil?
        if response_value != value
          "expected details '#{key}' to equal '#{value}' but got '#{response_value}'"
        end
      end

      def check_body
        "details body doesn't match" unless body_is_equivalent?
      end

      def body_is_equivalent?
        content_body = content_item["details"]["body"]
        content_body.gsub!(/<td>\s*<\/td>/, "<td>&nbsp;</td>") if content_body
        expected_body = expected_details[:body]
        EquivalentXml.equivalent?(
          string_to_xml(content_body),
          string_to_xml(expected_body)
        )
      end

      def string_to_xml(string)
        Nokogiri::HTML(string)
      end
    end
  end
end
