class Admin::SupportingDocumentsController < Admin::BaseController
  before_filter :authenticate!
  before_filter :find_document, only: [:new, :create]
  before_filter :find_supporting_document, only: [:show]

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

  private

  def find_document
    @document = Document.find(params[:document_id])
  end

  def find_supporting_document
    @supporting_document = SupportingDocument.find(params[:id])
  end
end