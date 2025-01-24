class ContentBlockManager::ContentBlock::Editions::WorkflowController < ContentBlockManager::BaseController
  include CanScheduleOrPublish
  include Workflow::ShowMethods
  include Workflow::UpdateMethods

  def show
    step = params[:step].to_sym
    action = Workflow::Step.by_name(step)&.show_action

    if action
      @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
      @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)
      send(action)
    else
      raise ActionController::RoutingError, "Step #{step} does not exist"
    end
  end

  def update
    step = params[:step].to_sym
    action = Workflow::Step.by_name(step)&.update_action

    if action
      @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])
      @schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(@content_block_edition.document.block_type)
      send(action)
    else
      raise ActionController::RoutingError, "Step #{step} does not exist"
    end
  end

  def context
    "Edit content block"
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
