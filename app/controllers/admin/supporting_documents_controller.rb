class Admin::SupportingDocumentsController < Admin::BaseController
  before_filter :find_document, only: [:new, :create]
  before_filter :find_supporting_document, only: [:show, :edit, :update]

  def new
    @supporting_document = @document.supporting_documents.build(params[:supporting_document])
  end

  def create
    @supporting_document = @document.supporting_documents.build(params[:supporting_document])
    if @supporting_document.save
      redirect_to admin_document_path(@document), notice: "The supporting document was added successfully"
    else
      flash[:alert] = "There was a problem: #{@supporting_document.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @supporting_document.update_attributes(params[:supporting_document])
      redirect_to admin_supporting_document_path(@supporting_document), notice: "The supporting document was updated successfully"
    else
      flash[:alert] = "There was a problem: #{@supporting_document.errors.full_messages.to_sentence}"
      render :edit
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = %{This document has been saved since you opened it. Your version appears at the top and the latest version appears at the bottom. Please incorporate any relevant changes into your version and then save it.}
    @conflicting_supporting_document = SupportingDocument.find(params[:id])
    @supporting_document.lock_version = @conflicting_supporting_document.lock_version
    render action: "edit"
  end

  private

  def find_document
    @document = Document.find(params[:document_id])
  end

  def find_supporting_document
    @supporting_document = SupportingDocument.find(params[:id])
  end
end