module ContentBlock
  class FindAndReplaceEmbedCodesService
    def self.call(html)
      new(html).call
    end

    def call
      embed_content_references.uniq.each do |reference|
        content_block = content_blocks.find do |c|
          c.fetch("content_id_aliases").first.fetch("name") == reference.identifier
        end
        next if content_block.nil?

        html.gsub!(
          reference.embed_code,
          render_block(content_block: content_block, embed_code: reference.embed_code),
        )
      end

      html
    end

  private

    attr_reader :html

    def initialize(html)
      @html = html
    end

    def embed_content_references
      @embed_content_references ||= ContentBlockTools::ContentBlockReference.find_all_in_document(html)
    end

    def unique_identifiers
      embed_content_references.uniq.map(&:identifier)
    end

    def content_blocks
      @content_blocks ||= get_content_items_from_publishing_api
    end

    def get_content_items_from_publishing_api
      Services
        .publishing_api
        .get_content_items(
          content_id_aliases: unique_identifiers,
          fields: %w[title content_id content_id_aliases details document_type],
          states: %w[published],
        )["results"]
    end

    def render_block(content_block:, embed_code:)
      ContentBlockTools::ContentBlock.new(
        document_type: content_block.fetch("document_type"),
        content_id: content_block.fetch("content_id"),
        title: content_block.fetch("title"),
        details: content_block.fetch("details"),
        embed_code: embed_code,
      ).render
    end
  end
end
