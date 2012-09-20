class Admin::EditionWorkflowController < Admin::BaseController
  include PublicDocumentRoutesHelper

  before_filter :find_edition
  before_filter :lock_edition
  before_filter :set_change_note
  before_filter :set_minor_change_flag

  rescue_from ActiveRecord::StaleObjectError do
    redirect_to admin_edition_path(@edition), alert: "This document has been edited since you viewed it; you are now viewing the latest version"
  end

  rescue_from ActiveRecord::RecordInvalid do
    redirect_to admin_edition_path(@edition),
      alert: "Unable to #{params[:action]} this edition because it is invalid (#{@edition.errors.full_messages.to_sentence}). " +
             "Please edit it and try again."
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
    if @edition.publish_as(current_user, force: params[:force].present?)
      users_to_notify(@edition).each do |user|
        Notifications.edition_published(user, @edition, admin_edition_url(@edition), public_document_url(@edition)).deliver
      end
      redirect_to admin_editions_path(state: :published), notice: "The document #{@edition.title} has been published"
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

  private

  def users_to_notify(edition)
    edition.authors.select(&:has_email?).reject { |a| a == current_user}
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
end
