require "net/http"
require "json"
require "uri"

module ContentBlockManager
  class GetPreviewContent
    def initialize(content_id:, content_block_edition:)
      @content_id = content_id
      @content_block_edition = content_block_edition
    end

    def preview_content
      {
        title: content_item["title"],
        html:,
      }
    end

  private

    def html
      @html ||= preview_html
    end

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

    def preview_html
      uri = URI(frontend_path)
      nokogiri_html = Nokogiri::HTML.parse(Net::HTTP.get(uri))
      replace_existing_content_blocks(nokogiri_html)
    end

    def replace_existing_content_blocks(nokogiri_html)
      existing_content_block_spans(nokogiri_html).each do |span|
        span.replace @content_block_edition.render
      end
      nokogiri_html
    end

    def existing_content_block_spans(nokogiri_html)
      nokogiri_html.css("span[data-content-id=\"#{@content_block_edition.document.content_id}\"]")
    end
  end
end
