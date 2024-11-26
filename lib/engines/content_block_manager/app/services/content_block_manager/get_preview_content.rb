require "net/http"
require "json"
require "uri"

module ContentBlockManager
  class GetPreviewContent
    def self.for_content_id(content_id:, content_block_edition:)
      new(content_id:, content_block_edition:).for_content_id
    end

    def for_content_id
      ContentBlockManager::PreviewContent.new(title: content_item["title"], html:)
    end

  private

    def initialize(content_id:, content_block_edition:)
      @content_id = content_id
      @content_block_edition = content_block_edition
    end

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
      nokogiri_html = html_snapshot_from_frontend(uri)
      replace_existing_content_blocks(nokogiri_html)
    end

    def replace_existing_content_blocks(nokogiri_html)
      replace_blocks(nokogiri_html)
      style_blocks(nokogiri_html)
      nokogiri_html
    end

    def replace_blocks(nokogiri_html)
      @preview_content_block_render ||= @content_block_edition.render
      content_block_spans(nokogiri_html).each do |span|
        span.replace @preview_content_block_render
      end
    end

    BLOCK_STYLE = "background-color: yellow;".freeze

    def style_blocks(nokogiri_html)
      content_block_spans(nokogiri_html).each do |span|
        span["style"] = BLOCK_STYLE
      end
    end

    def content_block_spans(nokogiri_html)
      nokogiri_html.css("span[data-content-id=\"#{@content_block_edition.document.content_id}\"]")
    end

    ERROR_HTML = "<html><body><p>Preview not found</p></body></html>".freeze

    def html_snapshot_from_frontend(uri)
      begin
        raw_html = Net::HTTP.get(uri)
      rescue StandardError
        raw_html = ERROR_HTML
      end
      Nokogiri::HTML.parse(raw_html)
    end
  end
end
