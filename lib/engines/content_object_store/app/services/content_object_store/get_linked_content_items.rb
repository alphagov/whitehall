module ContentObjectStore
  class GetLinkedContentItems
    PageData = Data.define(:total_items, :total_pages, :current_page)

    API_FIELDS = %w[title document_type links link_set_links content_id base_path].freeze

    def initialize(content_block_document:, page:)
      @block_type = content_block_document.block_type
      @content_id = content_block_document.content_id
      @page = page || 1
    end

    def items
      content_items["results"].map do |item|
        ContentObjectStore::ContentItem.new(
          title: item["title"],
          base_path: item["base_path"],
          document_type: item["document_type"],
          organisation: organisations.find { |o| o.content_id == organisation_id_for_content_item(item) },
        )
      end
    end

    def page_data
      PageData.new(
        total_items: content_items["total"],
        total_pages: content_items["pages"],
        current_page: content_items["current_page"],
      )
    end

    def arguments
      {
        "link_embed" => content_id,
        "fields" => API_FIELDS,
        "page" => page,
      }
    end

  private

    attr_reader :block_type, :content_id, :page

    def content_items
      @content_items ||= Services.publishing_api.get_content_items(**arguments)
    end

    def organisations
      Organisation.where(content_id: content_items["results"].map { |o| organisation_id_for_content_item(o) }.compact)
    end

    def organisation_id_for_content_item(content_item)
      links = content_item["links"].merge(content_item["link_set_links"])
      links["primary_publishing_organisation"]&.first
    end
  end
end
