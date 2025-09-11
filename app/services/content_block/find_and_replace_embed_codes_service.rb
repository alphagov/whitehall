module ContentBlock
  class FindAndReplaceEmbedCodesService
    def self.call(html)
      new(html).call
    end

    def call
      embed_content_references.uniq.each do |reference|
        content_block = content_blocks.find do |c|
          c.document.content_id == reference.identifier || c.document.content_id_alias == reference.identifier
        end
        next if content_block.nil?

        html.gsub!(reference.embed_code, content_block.render(reference.embed_code))
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

    def identifiers
      embed_content_references.map(&:identifier)
    end

    def content_blocks
      @content_blocks ||= begin
        scope = ContentBlockManager::ContentBlock::Edition.current_versions
        scope.where(document: { content_id: identifiers })
             .or(scope.where(document: { content_id_alias: identifiers }))
      end
    end
  end
end
