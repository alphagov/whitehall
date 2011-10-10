class DocumentsController < ApplicationController
  def index
    @policies, @publications = Policy.published, Publication.published
  end

  def show
    unless @document = Document.from_public_identity(params[:id])
      render text: "Not found", status: :not_found
    end
  end
end