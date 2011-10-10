class Admin::EditionsController < Admin::BaseController
  before_filter :authenticate!
  before_filter :find_edition, only: [:show, :edit, :update, :submit, :publish, :revise, :fact_check]

  def index
    @editions = Edition.unsubmitted
  end

  def submitted
    @editions = Edition.submitted
  end

  def published
    @editions = Edition.published
  end

  def new
    @edition = document_class.new
  end

  def create
    @edition = document_class.new(params[:edition].merge(author: current_user, document_identity: DocumentIdentity.new))
    if @edition.save
      redirect_to admin_edition_path(@edition), notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      render action: "new"
    end
  end

  def edit
  end

  def update
    if @edition.update_attributes(params[:edition])
      redirect_to admin_edition_path(@edition),
        notice: "The document has been saved"
    else
      flash.now[:alert] = "There are some problems with the document"
      render action: "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = %{This document has been saved since you opened it. Your version appears on the left and the latest version appears on the right. Please incorporate any relevant changes into your version and then save it.}
    @conflicting_edition = Edition.find(params[:id])
    @edition.lock_version = @conflicting_edition.lock_version
    render action: "edit"
  end

  def submit
    @edition.update_attributes(submitted: true)
    redirect_to admin_edition_path(@edition),
      notice: "Your document has been submitted for review by a second pair of eyes"
  end

  def publish
    if @edition.publish_as!(current_user, params[:edition][:lock_version])
      redirect_to published_admin_editions_path, notice: "The document #{@edition.title} has been published"
    else
      redirect_to admin_edition_path(@edition), alert: @edition.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_edition_path(@edition), alert: "This document has been edited since you viewed it; you are now viewing the latest version"
  end

  def revise
    edition = @edition.build_draft(current_user)
    if edition.save
      redirect_to edit_admin_edition_path(edition)
    else
      redirect_to edit_admin_edition_path(@edition.document_identity.editions.draft.first),
        alert: edition.errors.full_messages.to_sentence
    end
  end

  private

  def document_class
    @document_class ||= params[:document_type] == "Publication" ? Publication : Policy
  end

  def find_edition
    @edition = Edition.find(params[:id])
  end
end