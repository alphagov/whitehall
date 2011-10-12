class Admin::SupportingDocumentsController < Admin::BaseController
  before_filter :authenticate!

  def new
    @document = Document.find(params[:document_id])
    @supporting_document = @document.supporting_documents.build(params[:supporting_document])
  end

  def create
    @document = Document.find(params[:document_id])
    @supporting_document = @document.supporting_documents.build(params[:supporting_document])
    if @supporting_document.save
      redirect_to admin_document_path(@document), notice: "The supporting document was added successfully"
    else
      flash[:alert] = "There was a problem: #{@supporting_document.errors.full_messages.to_sentence}"
      render :new
    end
  end
end