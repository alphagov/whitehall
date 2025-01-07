require "net/http"
require "json"
require "uri"

module ContentBlockManager
  class GetHostContentItems
    attr_reader :content_id, :page, :order

    DEFAULT_ORDER = "-unique_pageviews".freeze

    def initialize(content_id:, page: nil, order: nil)
      self.content_id = content_id
      self.page = page
      self.order = order || DEFAULT_ORDER
    end

    def self.by_embedded_document(content_block_document:, page: nil, order: nil)
      new(content_id: content_block_document.content_id, page:, order:).items
    end

    def items
      items = content_items["results"].map do |item|
        ContentBlockManager::HostContentItem.new(
          title: item["title"],
          base_path: item["base_path"],
          document_type: item["document_type"],
          publishing_organisation: item["primary_publishing_organisation"],
          publishing_app: item["publishing_app"],
          last_edited_by_editor: editor_for_uid(item["last_edited_by_editor_id"]),
          last_edited_by_editor_id: item["last_edited_by_editor_id"],
          last_edited_at: item["last_edited_at"],
          unique_pageviews: item["unique_pageviews"],
          instances: item["instances"],
          host_content_id: item["host_content_id"],
        )
      end

      ContentBlockManager::HostContentItems.new(
        items:,
        total: content_items["total"],
        total_pages: content_items["total_pages"],
        rollup:,
      )
    end

    def rollup
      ContentBlockManager::HostContentItems::Rollup.new(
        views: content_items["rollup"]["views"],
        locations: content_items["rollup"]["locations"],
        instances: content_items["rollup"]["instances"],
        organisations: content_items["rollup"]["organisations"],
      )
    end

  private

    attr_writer :content_id, :page, :order

    def content_items
      @content_items ||= begin
        response = Services.publishing_api.get_host_content_for_content_id(@content_id, { page:, order: }.compact)
        response.parsed_content
      end
    end

    def editor_for_uid(uid)
      editors.find { |editor| editor.uid == uid }
    end

    def editors
      @editors ||= editor_uuids.present? ? ContentBlockManager::HostContentItem::Editor.with_uuids(editor_uuids) : []
    end

    def editor_uuids
      content_items["results"].map { |c| c["last_edited_by_editor_id"] }.compact
    end
  end
end
