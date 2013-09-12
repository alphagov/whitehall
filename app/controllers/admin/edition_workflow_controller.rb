class Admin::EditionWorkflowController < Admin::BaseController
  include PublicDocumentRoutesHelper

  before_filter :find_edition
  before_filter :enforce_permissions!
  before_filter :limit_edition_access!
  before_filter :lock_edition
  before_filter :set_change_note
  before_filter :set_minor_change_flag

  rescue_from ActiveRecord::StaleObjectError do
    redirect_to admin_edition_path(@edition), alert: "This document has been edited since you viewed it; you are now viewing the latest version"
  end

  rescue_from ActiveRecord::RecordInvalid do
    redirect_to admin_edition_path(@edition),
      alert: "Unable to #{action_name_as_human_interaction(params[:action])} because it is invalid (#{@edition.errors.full_messages.to_sentence}). " +
             "Please edit it and try again."
  end

  rescue_from Transitions::InvalidTransition do
    redirect_to admin_edition_path(@edition),
      alert: "Unable to #{action_name_as_human_interaction(params[:action])} because it is not ready yet. Please try again."
  end

  def enforce_permissions!
    case action_name
    when 'submit', 'unschedule', 'convert_to_draft'
      enforce_permission!(:update, @edition)
    when 'reject'
      enforce_permission!(:reject, @edition)
    when 'publish', 'schedule'
      if params[:force].present?
        enforce_permission!(:force_publish, @edition)
      else
        enforce_permission!(:publish, @edition)
      end
    when 'force_publish'
      enforce_permission!(:force_publish, @edition)
    when 'unpublish'
      enforce_permission!(:unpublish, @edition)
    when 'approve_retrospectively'
      enforce_permission!(:approve, @edition)
    else
      raise Whitehall::Authority::Errors::InvalidAction.new(action_name)
    end
  end

  def submit
    @edition.submit!
    redirect_to admin_edition_path(@edition),
      notice: "Your document has been submitted for review by a second pair of eyes"
  end

  def reject
    @edition.reject!
    users_to_notify(@edition).each do |user|
      Notifications.edition_rejected(user, @edition, admin_edition_url(@edition)).deliver
    end
    redirect_to new_admin_edition_editorial_remark_path(@edition),
      notice: "Document rejected; please explain why in an editorial remark"
  end

  def publish
    if params[:force].present? && params[:reason].blank?
      redirect_to admin_edition_path(@edition), alert: "You cannot force publish a document without a reason"
    else
      if @edition.publish_as(current_user, force: params[:force].present?)
        users_to_notify(@edition).each do |user|
          Notifications.edition_published(user, @edition, admin_edition_url(@edition), public_document_url(@edition)).deliver
        end
        if params[:force].present? && params[:reason].present?
          @edition.editorial_remarks.create(body: "Force published: #{params[:reason]}", author: current_user)
        end
        redirect_to admin_editions_path(state: :published), notice: "The document #{@edition.title} has been published"
      else
        redirect_to admin_edition_path(@edition), alert: @edition.errors.full_messages.to_sentence
      end
    end
  end

  def force_publish
  end

  def unpublish
    if @edition.unpublish_as(current_user, params[:unpublishing])
        redirect_options = {notice: "This document has been unpublished and will no longer appear on the public website"}
    else
      redirect_options = {alert: @edition.errors.full_messages.to_sentence}
    end
    redirect_to admin_edition_path(@edition), redirect_options
  end

  def schedule
    if @edition.schedule_as(current_user, force: params[:force].present?)
      redirect_to admin_editions_path(state: :scheduled), notice: "The document #{@edition.title} has been scheduled for publication"
    else
      redirect_to admin_edition_path(@edition), alert: @edition.errors.full_messages.to_sentence
    end
  end

  def unschedule
    if @edition.unschedule_as(current_user)
      redirect_to admin_editions_path(state: :submitted), notice: "The document #{@edition.title} has been unscheduled"
    else
      redirect_to admin_edition_path(@edition), alert: @edition.errors.full_messages.to_sentence
    end
  end

  def approve_retrospectively
    if @edition.approve_retrospectively_as(current_user)
      redirect_to admin_edition_path(@edition),
        notice: "Thanks for reviewing; this document is no longer marked as force-published"
    else
      redirect_to admin_edition_path(@edition), alert: @edition.errors.full_messages.to_sentence
    end
  end

  def convert_to_draft
    @edition.convert_to_draft!
    redirect_to admin_editions_path(session_filters.merge(state: :imported)),
      notice: "The imported document #{@edition.title} has been converted into a draft"
  end

  private

  def users_to_notify(edition)
    edition.authors.uniq.select(&:has_email?).reject { |a| a == current_user }
  end

  def find_edition
    @edition = Edition.find(params[:id])
  end

  def lock_edition
    if params[:lock_version]
      @edition.lock_version = params[:lock_version]
    else
      render text: 'All workflow actions require a lock version', status: 422
    end
  end

  def set_change_note
    if params[:edition] && params[:edition][:change_note]
      @edition.change_note = params[:edition][:change_note]
    end
  end

  def set_minor_change_flag
    if params[:edition] && params[:edition][:minor_change]
      @edition.minor_change = params[:edition][:minor_change]
    end
  end

  def action_name_as_human_interaction(action_name)
    case action_name.to_s
    when 'convert_to_draft'
      "convert this imported edition to a draft"
    else
      "#{action_name} this edition"
    end
  end

  def session_filters
    session[:document_filters] || {}
  end
end
