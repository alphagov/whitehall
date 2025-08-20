module Presenters
  module PublishingApi
    module PayloadHeadingsHelper
      def extract_headings(govspeak)
        return {} unless govspeak

        body_headings = Govspeak::Document.new(govspeak).structured_headers
        headers = remove_empty_headers(body_headings.map(&:to_h))
        headers = remove_links_in_headers(headers)

        headers.empty? ? {} : { headers: headers }
      end

    private

      def remove_empty_headers(body_headings)
        body_headings.each do |body_heading|
          body_heading.delete_if { |k, v| k == :headers && v.empty? }
          remove_empty_headers(body_heading[:headers]) if body_heading.key?(:headers)
        end
      end

      def remove_links_in_headers(body_headings)
        body_headings.each do |body_heading|
          body_heading[:text].gsub!(/\[(.+)\]\((.*)\)/, '\1')
          remove_links_in_headers(body_heading[:headers]) if body_heading.key?(:headers)
        end
      end
    end
  end
end
