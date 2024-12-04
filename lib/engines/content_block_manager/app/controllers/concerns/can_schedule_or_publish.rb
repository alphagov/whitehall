module CanScheduleOrPublish
  extend ActiveSupport::Concern

  def schedule_or_publish(template = "content_block_manager/content_block/editions/workflow/schedule_publishing")
    @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

    if params[:schedule_publishing].blank?
      @content_block_edition.errors.add(:schedule_publishing, "cannot be blank")
      raise ActiveRecord::RecordInvalid, @content_block_edition
    elsif params[:schedule_publishing] == "schedule"
      ContentBlockManager::ScheduleEditionService.new(@schema).call(@content_block_edition, scheduled_publication_params)
    else
      publish and return
    end

    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: @content_block_edition.id,
                                                                                        step: :confirmation,
                                                                                        is_scheduled: true)
  rescue ActiveRecord::RecordInvalid
    render template
  end

  def publish
    new_edition = ContentBlockManager::PublishEditionService.new.call(@content_block_edition)
    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: new_edition.id, step: :confirmation)
  end
end
