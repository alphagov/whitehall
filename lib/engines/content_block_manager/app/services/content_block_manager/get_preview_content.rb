require "net/http"
require "json"
require "uri"

module ContentBlockManager
  class GetPreviewContent
    def initialize(content_id:)
      @content_id = content_id
    end

    def preview_content
      {
        title: content_item["title"],
        html:,
      }
    end

  private

    def content_item
      @content_item ||= begin
        response = Services.publishing_api.get_content(@content_id)
        response.parsed_content
      end
    end

    def frontend_base_path
      Rails.env.development? ? Plek.external_url_for("government-frontend") : Plek.website_root
    end

    def frontend_path
      frontend_base_path + content_item["base_path"]
    end

    def html
      uri = URI(frontend_path)
      @html ||= Nokogiri::HTML.parse(Net::HTTP.get(uri))
    end
  end
end
