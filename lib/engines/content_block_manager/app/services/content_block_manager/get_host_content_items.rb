require "net/http"
require "json"
require "uri"

module ContentBlockManager
  class GetHostContentItems
    attr_reader :content_id

    def initialize(content_id:)
      self.content_id = content_id
    end

    def self.by_embedded_document(content_block_document:)
      new(content_id: content_block_document.content_id).items
    end

    def items
      content_items["results"].map do |item|
        ContentBlockManager::HostContentItem.new(
          title: item["title"],
          base_path: item["base_path"],
          document_type: item["document_type"],
          publishing_organisation: item["primary_publishing_organisation"],
          publishing_app: item["publishing_app"],
          last_edited_by_editor_id: item["last_edited_by_editor_id"],
          last_edited_at: item["last_edited_at"],
          page_views: page_views_for_base_path(item["base_path"]),
        )
      end
    end

  private

    attr_writer :content_id

    def page_views_for_base_path(base_path)
      page_views.find { |p| p.path == base_path }&.page_views || "0"
    end

    def page_views
      @page_views ||= page_views_service.new(paths: base_paths).call
    end

    def page_views_service
      ENV["BIGQUERY_PROJECT_ID"].blank? ? ContentBlockManager::PageViewsService::Local : ContentBlockManager::PageViewsService::Google
    end

    def base_paths
      content_items["results"].map do |item|
        item["base_path"]
      end
    end

    def content_items
      @content_items ||= begin
        response = Services.publishing_api.get_content_by_embedded_document(@content_id)
        response.parsed_content
      end
    end
  end
end
