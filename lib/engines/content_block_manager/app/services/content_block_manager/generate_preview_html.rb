require "net/http"
require "json"
require "uri"

module ContentBlockManager
  class GeneratePreviewHtml
    include ContentBlockManager::Engine.routes.url_helpers

    def initialize(content_id:, content_block_edition:, base_path:)
      @content_id = content_id
      @content_block_edition = content_block_edition
      @base_path = base_path
    end

    def call
      uri = URI(frontend_path)
      nokogiri_html = html_snapshot_from_frontend(uri)
      update_local_link_paths(nokogiri_html)
      add_draft_style(nokogiri_html)
      replace_existing_content_blocks(nokogiri_html).to_s
    end

  private

    BLOCK_STYLE = "background-color: yellow;".freeze
    ERROR_HTML = "<html><body><p>Preview not found</p></body></html>".freeze

    attr_reader :content_block_edition, :content_id, :base_path

    def frontend_path
      frontend_base_path + base_path
    end

    def frontend_base_path
      Rails.env.development? ? Plek.external_url_for("government-frontend") : Plek.website_root
    end

    def html_snapshot_from_frontend(uri)
      begin
        raw_html = Net::HTTP.get(uri)
      rescue StandardError
        raw_html = ERROR_HTML
      end
      Nokogiri::HTML.parse(raw_html)
    end

    def update_local_link_paths(nokogiri_html)
      url = content_block_manager_content_block_host_content_preview_path(id: content_block_edition.id, host_content_id: content_id)
      nokogiri_html.css("a").each do |link|
        next if link[:href].start_with?("//") || link[:href].start_with?("http")

        link[:href] = "#{url}?base_path=#{link[:href]}"
        link[:target] = "_parent"
      end

      nokogiri_html
    end

    def add_draft_style(nokogiri_html)
      nokogiri_html.css("body").each do |body|
        body["class"] ||= ""
        body["class"] += " draft"
      end
      nokogiri_html
    end

    def replace_existing_content_blocks(nokogiri_html)
      replace_blocks(nokogiri_html)
      style_blocks(nokogiri_html)
      nokogiri_html
    end

    def replace_blocks(nokogiri_html)
      content_block_spans(nokogiri_html).each do |span|
        span.replace content_block_edition.render
      end
    end

    def style_blocks(nokogiri_html)
      content_block_spans(nokogiri_html).each do |span|
        span["style"] = BLOCK_STYLE
      end
    end

    def content_block_spans(nokogiri_html)
      nokogiri_html.css("span[data-content-id=\"#{@content_block_edition.document.content_id}\"]")
    end
  end
end
