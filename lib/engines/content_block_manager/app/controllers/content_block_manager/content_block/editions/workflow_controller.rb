class ContentBlockManager::ContentBlock::Editions::WorkflowController < ContentBlockManager::BaseController
  include CanScheduleOrPublish

  include Workflow::Steps
  include Workflow::ShowMethods
  include Workflow::UpdateMethods

  def show
    action = current_step&.show_action

    if action
      send(action)
    else
      raise ActionController::RoutingError, "Step #{params[:step]} does not exist"
    end
  end

  def cancel
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
  end

  def update
    action = current_step&.update_action

    if action
      send(action)
    else
      raise ActionController::RoutingError, "Step #{params[:step]} does not exist"
    end
  end

  def context
    @content_block_edition.title
  end
  helper_method :context

private

  def review_url
    content_block_manager.content_block_manager_content_block_workflow_path(
      @content_block_edition,
      step: :review,
    )
  end
end
