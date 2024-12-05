class ContentBlockManager::ContentBlock::Documents::ScheduleController < ContentBlockManager::BaseController
  include CanScheduleOrPublish

  def edit
    document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
    @content_block_edition = document.latest_edition
  end

  def update
    document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
    @content_block_edition = document.latest_edition
    schedule_or_publish("content_block_manager/content_block/documents/schedule/edit")
  end
end
