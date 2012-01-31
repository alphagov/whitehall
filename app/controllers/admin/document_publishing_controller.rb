class Admin::DocumentPublishingController < Admin::BaseController
  before_filter :find_document
  before_filter :lock_document
  before_filter :set_change_note

  def create
    if @document.publish_as(current_user, force: params[:force].present?)
      redirect_to published_admin_documents_path, notice: "The document #{@document.title} has been published"
    else
      redirect_to admin_document_path(@document), alert: @document.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_document_path(@document), alert: "This document has been edited since you viewed it; you are now viewing the latest version"
  end

  private

  def find_document
    @document = Document.find(params[:document_id])
  end

  def lock_document
    if params[:document] && params[:document][:lock_version]
      @document.lock_version = params[:document][:lock_version]
    end
  end

  def set_change_note
    if params[:document] && params[:document][:change_note]
      @document.change_note = params[:document][:change_note]
    end
  end
end