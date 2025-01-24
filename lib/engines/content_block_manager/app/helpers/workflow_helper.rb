module WorkflowHelper
  def back_path(content_block_edition, current_step)
    if current_step == "review" && content_block_edition.document.is_new_block?
      content_block_manager.content_block_manager_content_block_documents_path
    else
      step = Workflow::Step.by_name(current_step)&.previous_step
      return nil unless step

      content_block_manager.content_block_manager_content_block_workflow_path(
        content_block_edition,
        step: step.name,
      )
    end
  end
end
