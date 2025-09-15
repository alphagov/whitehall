module ContentBlock
  class FindAndReplaceEmbedCodesService
    def self.call(html)
      new(html).call
    end

    def call
      unique_embedded_content_references.each do |reference|
        replace_embed_code_with_rendered_block_for(reference)
      end

      html
    end

  private

    attr_reader :html

    def initialize(html)
      @html = html
    end

    def unique_embedded_content_references
      @unique_embedded_content_references ||=
        ContentBlockTools::ContentBlockReference.find_all_in_document(html).uniq
    end

    def identifiers
      unique_embedded_content_references.map(&:identifier)
    end

    def content_items
      @content_items ||= get_content_items_from_publishing_api.map do |result|
        PublishingApiContentItem.new(result)
      end
    end

    def get_content_items_from_publishing_api
      Services
        .publishing_api
        .get_content_items(
          content_id_aliases: identifiers,
          fields: %w[title content_id content_id_aliases details document_type],
          states: %w[published],
        )["results"]
    end

    def replace_embed_code_with_rendered_block_for(reference)
      content_item = content_items.find do |item|
        item.content_id_alias == reference.identifier
      end
      return unless content_item

      html.gsub!(
        reference.embed_code,
        render_block(content_item: content_item, embed_code: reference.embed_code),
      )
    end

    def render_block(content_item:, embed_code:)
      ContentBlockTools::ContentBlock.new(
        document_type: content_item.document_type,
        content_id: content_item.content_id,
        title: content_item.title,
        details: content_item.details,
        embed_code: embed_code,
      ).render
    end

    class PublishingApiContentItem
      def initialize(result_hash)
        @document_type = result_hash.fetch("document_type")
        @content_id = result_hash.fetch("content_id")
        @title = result_hash.fetch("title")
        @details = result_hash.fetch("details")
        @content_id_alias = result_hash.fetch("content_id_aliases").first.fetch("name")
      end
      attr_reader :document_type, :content_id, :title, :details, :content_id_alias
    end
  end
end
