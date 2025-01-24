module Workflow::UpdateMethods
  extend ActiveSupport::Concern

  REVIEW_ERROR = Data.define(:attribute, :full_message)

  def validate_schedule
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    validate_scheduled_edition

    redirect_to_next_step
  rescue ActiveRecord::RecordInvalid
    render "content_block_manager/content_block/editions/workflow/schedule_publishing"
  end

  def update_internal_note
    @content_block_edition.update!(internal_change_note: edition_params[:internal_change_note])

    redirect_to_next_step
  end

  def update_change_note
    @content_block_edition.assign_attributes(change_note: edition_params[:change_note], major_change: edition_params[:major_change])
    @content_block_edition.save!(context: :change_note)

    redirect_to_next_step
  rescue ActiveRecord::RecordInvalid
    render :change_note
  end

  def validate_review_page
    if params[:is_confirmed].blank?
      @confirm_error_copy = I18n.t("content_block_edition.review_page.errors.confirm")
      @error_summary_errors = [{ text: @confirm_error_copy, href: "#is_confirmed-0" }]
      render :review
    else
      schedule_or_publish
    end
  end

private

  def redirect_to_next_step
    next_step = Workflow::Step.by_name(params[:step])&.next_step

    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(
      id: @content_block_edition.id,
      step: next_step&.name,
    )
  end
end
