module SyncChecker
  module Checks
    HttpStatusCheck = Struct.new(:disallowed_response_codes) do
      def call(response)
        failures = []

        if Array(disallowed_response_codes).include?(response.response_code)
          failures << "http response code #{response.response_code} returned for #{response.request.base_url}"
        end

        failures
      end
    end
  end
end
