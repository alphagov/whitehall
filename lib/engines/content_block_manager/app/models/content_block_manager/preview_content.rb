module ContentBlockManager
  class PreviewContent < Data.define(:title, :html, :instances_count)
    class << self
      def for_content_id(content_id:, content_block_edition:, base_path: nil)
        content_item = Services.publishing_api.get_content(content_id).parsed_content
        metadata = Services.publishing_api.get_host_content_item_for_content_id(
          content_block_edition.document.content_id,
          content_id,
        ).parsed_content
        html = ContentBlockManager::GeneratePreviewHtml.new(
          content_id:,
          content_block_edition:,
          base_path: base_path || content_item["base_path"],
        ).call

        ContentBlockManager::PreviewContent.new(
          title: content_item["title"],
          html:,
          instances_count: metadata["instances"],
        )
      end
    end
  end
end
