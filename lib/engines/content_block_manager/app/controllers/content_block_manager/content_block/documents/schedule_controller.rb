class ContentBlockManager::ContentBlock::Documents::ScheduleController < ContentBlockManager::BaseController
  include CanScheduleOrPublish

  def edit
    document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
    @content_block_edition = document.latest_edition
  end

  def update
    document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
    @content_block_edition = document.latest_edition.clone_edition(creator: current_user)

    validate_scheduled_edition

    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(@content_block_edition, step: :review)
  rescue ActiveRecord::RecordInvalid
    render "content_block_manager/content_block/documents/schedule/edit"
  end
end
