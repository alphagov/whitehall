module ContentBlockManager
  class FindAndReplaceEmbedCodesService
    def self.call(html)
      new(html).call
    end

    def call
      embed_content_references.each do |reference|
        content_block = content_blocks.find { |c| c.document.content_id == reference.content_id }
        next if content_block.nil?

        html.gsub!(reference.embed_code, content_block.render)
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

    def content_blocks
      @content_blocks ||= ContentBlockManager::ContentBlock::Edition.current_versions
      .where(document: { content_id: embed_content_references.map(&:content_id) })
    end
  end
end
