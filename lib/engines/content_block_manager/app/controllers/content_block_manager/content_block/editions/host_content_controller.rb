class ContentBlockManager::ContentBlock::Editions::HostContentController < ContentBlockManager::BaseController
  def preview
    host_content_id = params[:host_content_id]
    content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
    @preview_content = ContentBlockManager::GetPreviewContent.for_content_id(content_id: host_content_id, content_block_edition:)
  end
end
