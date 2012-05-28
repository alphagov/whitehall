class Admin::EditionWorkflowController < Admin::BaseController
  before_filter :find_edition
  before_filter :lock_edition
  before_filter :set_change_note
  before_filter :set_minor_change_flag

  rescue_from ActiveRecord::StaleObjectError do
    redirect_to admin_document_path(@edition), alert: "This document has been edited since you viewed it; you are now viewing the latest version"
  end

  def submit
    @edition.submit!
    redirect_to admin_document_path(@edition),
      notice: "Your document has been submitted for review by a second pair of eyes"
  end

  def reject
    @edition.reject!
    redirect_to new_admin_document_editorial_remark_path(@edition),
      notice: "Document rejected; please explain why in an editorial remark"
  end

  def publish
    if @edition.publish_as(current_user, force: params[:force].present?)
      redirect_to admin_documents_path(state: :published), notice: "The document #{@edition.title} has been published"
    else
      redirect_to admin_document_path(@edition), alert: @edition.errors.full_messages.to_sentence
    end
  end

  private

  def find_edition
    @edition = Edition.find(params[:id])
  end

  def lock_edition
    if params[:document] && params[:document][:lock_version]
      @edition.lock_version = params[:document][:lock_version]
    end
  end

  def set_change_note
    if params[:document] && params[:document][:change_note]
      @edition.change_note = params[:document][:change_note]
    end
  end

  def set_minor_change_flag
    if params[:document] && params[:document][:minor_change]
      @edition.minor_change = params[:document][:minor_change]
    end
  end
end
