class ContentBlockManager::ContentBlock::Documents::ScheduleController < ContentBlockManager::BaseController
  include CanScheduleOrPublish

  def edit
    document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
    @content_block_edition = document.latest_edition
  end

  def update
    document = ContentBlockManager::ContentBlock::Document.find(params[:document_id])
    @content_block_edition = document.latest_edition
    validate_update
  end

private

  def validate_update
    if params[:schedule_publishing].blank?
      @content_block_edition.errors.add(:schedule_publishing, "cannot be blank")
      raise ActiveRecord::RecordInvalid, @content_block_edition
    else
      schedule_or_publish
    end
  rescue ActiveRecord::RecordInvalid
    render "content_block_manager/content_block/documents/schedule/edit"
  end
end
