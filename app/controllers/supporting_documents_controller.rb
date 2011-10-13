class SupportingDocumentsController < ApplicationController
  before_filter :find_document
  before_filter :find_supporting_document

  def show
  end

  private

  def find_document
    unless @document = Document.published_as(params[:document_id])
      render text: "Not found", status: :not_found
    end
  end

  def find_supporting_document
    @supporting_document = @document.supporting_documents.find(params[:id])
  end
end