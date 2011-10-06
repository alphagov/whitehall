class DocumentsController < ApplicationController
  def index
    @policies, @publications = Policy.published, Publication.published
  end

  def show
    document = Document.find(params[:id])
    unless @published_edition = document.published_edition
      render text: "Not found", status: :not_found
    end
  end
end