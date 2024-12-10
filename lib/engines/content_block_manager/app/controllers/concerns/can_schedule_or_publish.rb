module CanScheduleOrPublish
  extend ActiveSupport::Concern

  def schedule_or_publish
    if params[:step] == ContentBlockManager::ContentBlock::Editions::WorkflowController::UPDATE_BLOCK_STEPS[:review_update] && params[:is_confirmed].blank?
      @confirm_error_copy = I18n.t("content_block_edition.review_page.errors.confirm")
      @error_summary_errors = [{ text: @confirm_error_copy, href: "#is_confirmed-0" }]
      render "content_block_manager/content_block/editions/workflow/review_update"
    else
      @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)

      if params[:schedule_publishing] == "schedule"
        ContentBlockManager::ScheduleEditionService.new(@schema).call(@content_block_edition, scheduled_publication_params)
      else
        publish and return
      end

      redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: @content_block_edition.id,
                                                                                          step: :confirmation,
                                                                                          is_scheduled: true)
    end
  end

  def publish
    new_edition = ContentBlockManager::PublishEditionService.new.call(@content_block_edition)
    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(id: new_edition.id, step: :confirmation)
  end
end
