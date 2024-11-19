class ContentBlockManager::ContentBlock::Editions::PreviewController < ContentBlockManager::BaseController
  def show
    host_content_id = params[:host_content_id]
    @preview_content = ContentBlockManager::GetPreviewContent.new(content_id: host_content_id).preview_content
  end
end
