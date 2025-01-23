module Workflow::UpdateMethods
  extend ActiveSupport::Concern

  REVIEW_ERROR = Data.define(:attribute, :full_message)

  UPDATE_ACTIONS = {
    review_links: :redirect_to_schedule,
    schedule_publishing: :validate_schedule,
    internal_note: :update_internal_note,
    change_note: :update_change_note,
    review_update: :validate_review_page,
    review: :validate_review_page,
  }.freeze

  def redirect_to_schedule
    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(
      id: @content_block_edition.id,
      step: :schedule_publishing,
    )
  end

  def validate_schedule
    @content_block_edition = ContentBlockManager::ContentBlock::Edition.find(params[:id])

    validate_scheduled_edition

    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(
      id: @content_block_edition.id,
      step: :internal_note,
    )
  rescue ActiveRecord::RecordInvalid
    render "content_block_manager/content_block/editions/workflow/schedule_publishing"
  end

  def update_internal_note
    @content_block_edition.update!(internal_change_note: edition_params[:internal_change_note])

    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(
      id: @content_block_edition.id,
      step: :change_note,
    )
  end

  def update_change_note
    @content_block_edition.assign_attributes(change_note: edition_params[:change_note], major_change: edition_params[:major_change])
    @content_block_edition.save!(context: :change_note)

    redirect_to content_block_manager.content_block_manager_content_block_workflow_path(
      id: @content_block_edition.id,
      step: :review_update,
    )
  rescue ActiveRecord::RecordInvalid
    render :change_note
  end

  def validate_review_page
    if params[:is_confirmed].blank?
      @confirm_error_copy = I18n.t("content_block_edition.review_page.errors.confirm")
      @error_summary_errors = [{ text: @confirm_error_copy, href: "#is_confirmed-0" }]
      @url = on_review_page? ? review_url : review_update_url
      render "content_block_manager/content_block/editions/workflow/review"
    else
      schedule_or_publish
    end
  end

private

  def on_review_page?
    params[:step] == :review
  end

  def on_review_update_page?
    params[:step] == :review_update
  end
end
