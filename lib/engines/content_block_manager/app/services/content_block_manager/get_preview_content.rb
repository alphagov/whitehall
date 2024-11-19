require "net/http"
require "json"
require "uri"

module ContentBlockManager
  class GetPreviewContent
    def initialize(content_id:)
      @content_id = content_id
    end

    def preview_content
      puts "content items results"
      puts content_item
      {
        title: content_item["title"],
        document_type: content_item["document_type"],
        publishing_app: content_item["publishing_app"],
        frontend_path:,
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
      # TODO: how to make opening this path secure?
      @html ||= Nokogiri::HTML(URI.open(frontend_path).read)
    end
  end
end
