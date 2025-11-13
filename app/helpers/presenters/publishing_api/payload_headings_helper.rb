module Presenters
  module PublishingApi
    module PayloadHeadingsHelper
      def extract_headings(govspeak, options = {})
        return {} unless govspeak

        body_headings = Govspeak::Document.new(govspeak, options).structured_headers
        headers = remove_empty_headers(body_headings.map(&:to_h))

        headers.empty? ? {} : { headers: headers }
      end

    private

      def remove_empty_headers(body_headings)
        body_headings.each do |body_heading|
          body_heading.delete_if { |k, v| k == :headers && v.empty? }
          remove_empty_headers(body_heading[:headers]) if body_heading.key?(:headers)
        end
      end
    end
  end
end
