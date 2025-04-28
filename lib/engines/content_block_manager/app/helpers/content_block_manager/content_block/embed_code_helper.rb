module ContentBlockManager::ContentBlock::EmbedCodeHelper
  def copy_embed_code_data_attributes(key, content_block_document)
    {
      module: "copy-embed-code",
      "embed-code": content_block_document.embed_code_for_field(key),
    }
  end

  # This generates a row containing the embed code for the field above it -
  # it will be deleted if javascript is enabled by copy-embed-code.js.
  def embed_code_row(key, content_block_document)
    {
      key: "Embed code",
      value: content_block_document.embed_code_for_field(key),
      data: {
        "embed-code-row": "true",
      },
    }
  end
end
