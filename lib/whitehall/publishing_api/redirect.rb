require "securerandom"

module Whitehall
  class PublishingApi
    class Redirect
      attr_reader :base_path

      def initialize(base_path, redirects, edition_content_id = nil)
        @redirects = redirects
        @base_path = base_path
        @edition_content_id = edition_content_id
      end

      def as_json
        data = {
          content_id: SecureRandom.uuid,
          base_path: base_path,
          format: "redirect",
          publishing_app: "whitehall",
          update_type: "major",
          redirects: redirects,
        }
        data.merge!(links: {can_be_replaced_by: [edition_content_id]}) if edition_content_id.present?
        data
      end

    private
      attr_reader :redirects, :edition_content_id
    end
  end
end
