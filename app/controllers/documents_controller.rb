class DocumentsController < ApplicationController
  def index
    @documents = Document.published
  end

  def show
    policy = Policy.find(params[:id])
    unless @edition = policy.editions.published.last
      render text: "Not found", status: :not_found
    end
  end
end