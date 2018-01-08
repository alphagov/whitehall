class Admin::EditionWorkflowController < Admin::BaseController
  include PublicDocumentRoutesHelper

  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!
  before_action :lock_edition
  before_action :set_change_note
  before_action :set_minor_change_flag
  before_action :ensure_reason_given_for_force_publishing, only: :force_publish

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
      enforce_permission!(:publish, @edition)
    when 'force_publish', 'confirm_force_publish', 'force_schedule'
      enforce_permission!(:force_publish, @edition)
    when 'unpublish', 'confirm_unpublish'
      enforce_permission!(:unpublish, @edition)
    when 'unwithdraw', 'confirm_unwithdraw'
      enforce_permission!(:unwithdraw, @edition)
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
      Notifications.edition_rejected(user, @edition, admin_edition_url(@edition)).deliver_now
    end
    redirect_to new_admin_edition_editorial_remark_path(@edition),
      notice: "Document rejected; please explain why in an editorial remark"
  end

  def publish
    edition_publisher = Whitehall.edition_services.publisher(@edition)
    if edition_publisher.perform!
      redirect_to admin_editions_path(session_filters || { state: :published }),
        notice: "The document #{@edition.title} has been published"
    else
      redirect_to admin_edition_path(@edition), alert: edition_publisher.failure_reason
    end
  end

  def confirm_force_publish
    unless @edition.valid?(:publish)
      return redirect_to admin_edition_path(@edition), alert: @edition.errors[:base].join('. ')
    end
  end

  def force_publish
    unless @edition.valid?(:publish)
      return redirect_to admin_edition_path(@edition), alert: @edition.errors[:base].join('. ')
    end

    edition_publisher = Whitehall.edition_services.force_publisher(@edition, user: current_user, remark: force_publish_reason)
    if edition_publisher.perform!
      redirect_to admin_editions_path(state: :published), notice: "The document #{@edition.title} has been published"
    else
      redirect_to admin_edition_path(@edition), alert: edition_publisher.failure_reason
    end
  end

  def confirm_unpublish
    @unpublishing = @edition.build_unpublishing(unpublishing_reason_id: UnpublishingReason::Withdrawn.id)
  end

  def unpublish
    @service_object = withdrawer_or_unpublisher_for(@edition)

    if @service_object.perform!
      redirect_to admin_edition_path(@edition), notice: unpublish_success_notice
    else
      @unpublishing = @edition.unpublishing
      flash.now[:alert] = @service_object.failure_reason
      render :confirm_unpublish
    end
  end

  def confirm_unwithdraw
  end

  def unwithdraw
    edition_unwithdrawer = Whitehall.edition_services.unwithdrawer(@edition, user: current_user)
    if edition_unwithdrawer.perform!
      new_edition = @edition.document.published_edition
      redirect_to admin_edition_path(new_edition), notice: "This document has been unwithdrawn"
    else
      flash.now[:alert] = edition_unwithdrawer.failure_reason
      render :confirm_unwithdraw
    end
  end

  def schedule
    # This will enqueue a `ScheduledPublishingWorker`
    edition_scheduler = Whitehall.edition_services.scheduler(@edition)
    if edition_scheduler.perform!
      redirect_to admin_editions_path(state: :scheduled), notice: "The document #{@edition.title} has been scheduled for publication"
    else
      redirect_to admin_edition_path(@edition), alert: edition_scheduler.failure_reason
    end
  end

  def force_schedule
    force_scheduler = Whitehall.edition_services.force_scheduler(@edition)
    if force_scheduler.perform!
      redirect_to admin_editions_path(state: :scheduled), notice: "The document #{@edition.title} has been force scheduled for publication"
    else
      redirect_to admin_edition_path(@edition), alert: force_scheduler.failure_reason
    end
  end

  def unschedule
    unscheduler = Whitehall.edition_services.unscheduler(@edition)
    if unscheduler.perform!
      redirect_to admin_editions_path(state: :submitted), notice: "The document #{@edition.title} has been unscheduled"
    else
      redirect_to admin_edition_path(@edition), alert: unscheduler.failure_reason
    end
  end

  def approve_retrospectively
    if @edition.approve_retrospectively
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

  def force_publish_reason
    "Force published: #{params[:reason]}"
  end

  def ensure_reason_given_for_force_publishing
    if params[:reason].blank?
      redirect_to admin_edition_path(@edition), alert: "You cannot force publish a document without a reason"
    end
  end

  def withdrawer_or_unpublisher_for(edition)
    if withdrawing?
      Whitehall.edition_services.withdrawer(@edition, user: current_user, remark: "Withdrawn", unpublishing: unpublishing_params)
    else
      Whitehall.edition_services.unpublisher(@edition, user: current_user, remark: "Reset to draft", unpublishing: unpublishing_params)
    end
  end

  def unpublishing_params
    params.fetch(:unpublishing, {}).permit(
      :unpublishing_reason_id, :alternative_url, :redirect, :explanation
    )
  end

  def unpublish_success_notice
    if withdrawing?
      "This document has been marked as withdrawn"
    else
      "This document has been unpublished and will no longer appear on the public website"
    end
  end

  def withdrawing?
    unpublishing_params[:unpublishing_reason_id] == UnpublishingReason::Withdrawn.id.to_s
  end

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
      render plain: 'All workflow actions require a lock version', status: 422
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
    (session[:document_filters] || {}).to_h
  end
end
