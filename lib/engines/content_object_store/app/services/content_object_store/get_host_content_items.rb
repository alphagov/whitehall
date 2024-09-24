require "net/http"
require "json"
require "uri"

module ContentObjectStore
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
        ContentObjectStore::HostContentItem.new(
          title: item["title"],
          base_path: item["base_path"],
          document_type: item["document_type"],
          publishing_organisation: item["primary_publishing_organisation"],
          publishing_app: item["publishing_app"],
        )
      end
    end

  private

    attr_writer :content_id

    def content_items
      @content_items ||= begin
        response = Services.publishing_api.get_content_by_embedded_document(@content_id)
        response.parsed_content
      end
    end
  end
end
