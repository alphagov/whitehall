class ContentBlockManager::ContentBlock::Editions::HostContentController < ContentBlockManager::BaseController
  def preview
    host_content_id = params[:host_content_id]
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @preview_content = ContentBlockManager::PreviewContent.for_content_id(
      content_id: host_content_id,
      content_block_edition: @content_block_edition,
      base_path: params[:base_path],
    )
  end
end
