class DocumentsController < ApplicationController
  def index
    @policies, @publications = Policy.published, Publication.published
  end

  def show
    document = DocumentIdentity.find(params[:id])
    unless @published_document = document.published_document
      render text: "Not found", status: :not_found
    end
  end
end