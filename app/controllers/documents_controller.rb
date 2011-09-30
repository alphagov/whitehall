class DocumentsController < ApplicationController
  def index
    @documents = Document.published
  end

  def show
    document = Document.find(params[:id])
    unless @published_edition = document.published_edition
      render text: "Not found", status: :not_found
    end
  end
end