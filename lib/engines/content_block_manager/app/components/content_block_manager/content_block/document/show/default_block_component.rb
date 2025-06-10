class ContentBlockManager::ContentBlock::Document::Show::DefaultBlockComponent < ViewComponent::Base
  def initialize(content_block_document:)
    @content_block_document = content_block_document
  end

private

  attr_reader :content_block_document

  def content_block_edition
    @content_block_edition = content_block_document.latest_edition
  end

  def block_content
    content_tag(:div, class: "govspeak") do
      content_block_edition.render(embed_code)
    end
  end

  def embed_code_row_value
    content_tag(:p, embed_code, class: "app-c-content-block-manager-default-block__embed_code")
  end

  def embed_code
    @embed_code ||= content_block_document.embed_code
  end

  def data_attributes
    {
      module: "copy-embed-code",
      "embed-code": embed_code,
    }
  end
end
