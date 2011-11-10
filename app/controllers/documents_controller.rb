class DocumentsController < ApplicationController
  before_filter :find_document, only: [:show]

  private

  def find_document
    unless @document = document_class.published_as(params[:id])
      render text: "Not found", status: :not_found
    end
  end

  def document_class
    Document
  end
end