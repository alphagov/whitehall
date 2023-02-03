class Admin::EditionWorkflowController < Admin::BaseController
  include HistoricContentConcern
  include PublicDocumentRoutesHelper

  layout :get_layout

  before_action :find_edition
  before_action :forbid_editing_of_historic_content!
  before_action :enforce_permissions!
  before_action :limit_edition_access!
  before_action :lock_edition
  before_action :set_change_note
  before_action :set_minor_change_flag
  before_action :ensure_reason_given_for_force_publishing, only: :force_publish
  before_action :set_previous_withdrawals, only: %i[confirm_unpublish unpublish]

  rescue_from ActiveRecord::StaleObjectError do
    redirect_to admin_edition_path(@edition), alert: "This document has been edited since you viewed it; you are now viewing the latest version"
  end

  rescue_from ActiveRecord::RecordInvalid do
    redirect_to admin_edition_path(@edition),
                alert: "Unable to #{action_name_as_human_interaction(params[:action])} because it is invalid (#{@edition.errors.full_messages.to_sentence}). Please edit it and try again."
  end

  rescue_from Transitions::InvalidTransition do
    redirect_to admin_edition_path(@edition),
                alert: "Unable to #{action_name_as_human_interaction(params[:action])} because it is not ready yet. Please try again."
  end

  def enforce_permissions!
    case action_name
    when "submit", "unschedule", "confirm_unschedule"
      enforce_permission!(:update, @edition)
    when "reject"
      enforce_permission!(:reject, @edition)
    when "publish", "schedule"
      enforce_permission!(:publish, @edition)
    when "force_publish", "confirm_force_publish", "force_schedule", "confirm_force_schedule"
      enforce_permission!(:force_publish, @edition)
    when "unpublish", "confirm_unpublish"
      enforce_permission!(:unpublish, @edition)
    when "unwithdraw", "confirm_unwithdraw"
      enforce_permission!(:unwithdraw, @edition)
    when "confirm_approve_retrospectively"
      enforce_permission!(:approve, @edition)
    when "approve_retrospectively"
      enforce_permission!(:approve, @edition)
    else
      raise Whitehall::Authority::Errors::InvalidAction, action_name
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
      MailNotifications.edition_rejected(user, @edition, admin_edition_url(@edition)).deliver_now
    end
    redirect_to new_admin_edition_editorial_remark_path(@edition),
                notice: "Document rejected; please explain why in an internal note"
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
    redirect_to admin_edition_path(@edition), alert: @edition.errors[:base].join(". ") and return unless @edition.valid?(:publish)
  end

  def force_publish
    unless @edition.valid?(:publish)
      return redirect_to admin_edition_path(@edition), alert: @edition.errors[:base].join(". ")
    end

    edition_publisher = Whitehall.edition_services.force_publisher(@edition, user: current_user, remark: force_publish_reason)
    if edition_publisher.perform!
      redirect_to admin_editions_path(state: :published), notice: "The document #{@edition.title} has been published"
    else
      redirect_to admin_edition_path(@edition), alert: edition_publisher.failure_reason
    end
  end

  def confirm_unpublish
    @unpublishing = @edition.build_unpublishing
  end

  def unpublish
    success, message = withdrawing? ? withdraw_edition : unpublish_edition

    if success
      redirect_to admin_edition_path(@edition), notice: message
    else
      @unpublishing = @edition.unpublishing || @edition.build_unpublishing(unpublishing_params)
      flash.now[:alert] = message if @unpublishing.errors.blank?
      render :confirm_unpublish
    end
  end

  def confirm_unwithdraw; end

  def unwithdraw
    edition_unwithdrawer = Whitehall.edition_services.unwithdrawer(@edition, user: current_user)
    if edition_unwithdrawer.perform!
      new_edition = @edition.document.live_edition
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

  def confirm_force_schedule; end

  def force_schedule
    force_scheduler = Whitehall.edition_services.force_scheduler(@edition)
    if force_scheduler.perform!
      redirect_to admin_editions_path(state: :scheduled), notice: "The document #{@edition.title} has been force scheduled for publication"
    else
      redirect_to admin_edition_path(@edition), alert: force_scheduler.failure_reason
    end
  end

  def confirm_unschedule; end

  def unschedule
    unscheduler = Whitehall.edition_services.unscheduler(@edition)
    if unscheduler.perform!
      redirect_to admin_editions_path(state: :submitted), notice: "The document #{@edition.title} has been unscheduled"
    else
      redirect_to admin_edition_path(@edition), alert: unscheduler.failure_reason
    end
  end

  def confirm_approve_retrospectively; end

  def approve_retrospectively
    if @edition.approve_retrospectively
      redirect_to admin_edition_path(@edition),
                  notice: "Thanks for reviewing; this document is no longer marked as force-published"
    else
      redirect_to admin_edition_path(@edition), alert: @edition.errors.full_messages.to_sentence
    end
  end

private

  def get_layout
    design_system_actions = %w[confirm_approve_retrospectively confirm_force_schedule confirm_unpublish confirm_unschedule confirm_unwithdraw unpublish confirm_force_publish]
    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def force_publish_reason
    "Force published: #{params[:reason]}"
  end

  def ensure_reason_given_for_force_publishing
    if params[:reason].blank?
      redirect_to admin_edition_path(@edition), alert: "You cannot force publish a document without a reason"
    end
  end

  def set_previous_withdrawals
    # The limit here is entirely arbitrary with the purpose of avoiding page-load performance issues on
    # documents with lots of withdrawals. This scenario is unlikely, but a limit is better than a timeout.
    @previous_withdrawals = @edition.document.withdrawals.last(50)
  end

  def withdraw_edition
    if new_withdrawal? || previous_withdrawal.present?
      withdrawer = Whitehall.edition_services.withdrawer(
        @edition,
        user: current_user,
        remark: "Withdrawn",
        unpublishing: unpublishing_params,
        previous_withdrawal:,
      )

      success = withdrawer.perform!
      message = if success
                  "This document has been marked as withdrawn"
                else
                  withdrawer.failure_reason
                end
    else
      success = false
      message = "Select which withdrawal date you want to use"
    end

    [success, message]
  end

  def unpublish_edition
    unpublisher = Whitehall.edition_services.unpublisher(
      @edition,
      user: current_user,
      remark: "Reset to draft",
      unpublishing: unpublishing_params,
    )

    success = unpublisher.perform!
    message = if success
                "This document has been unpublished and will no longer appear on the public website"
              else
                unpublisher.failure_reason
              end

    [success, message]
  end

  def unpublishing_params
    params.fetch(:unpublishing, {}).permit(
      :unpublishing_reason_id, :alternative_url, :redirect, :explanation
    )
  end

  def withdrawing?
    unpublishing_params[:unpublishing_reason_id] == UnpublishingReason::Withdrawn.id.to_s
  end

  def previous_withdrawal_id
    params["previous_withdrawal_id"]
  end

  def previous_withdrawal
    return if new_withdrawal?

    @previous_withdrawal ||= @edition.document.withdrawals.find_by(id: previous_withdrawal_id)
  end

  def new_withdrawal?
    previous_withdrawal_id == "new" || @edition.document.withdrawals.none?
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
      render plain: "All workflow actions require a lock version", status: :unprocessable_entity
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
    when "approve_retrospectively"
      "retrospectively approve this edition"
    when "confirm_unpublish"
      "unpublish this edition"
    when "confirm_force_publish"
      "force publish this edition"
    when "confirm_unwithdraw"
      "unwithdraw this edition"
    else
      "#{action_name.humanize(capitalize: false)} this edition"
    end
  end

  def session_filters
    (session[:document_filters] || {}).to_h
  end
end
