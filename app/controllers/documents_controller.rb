class DocumentsController < ApplicationController
  def index
    @policies, @publications = Policy.published, Publication.published
  end

  def show
    unless @document = Document.published_as(params[:id])
      render text: "Not found", status: :not_found
    end
  end
end