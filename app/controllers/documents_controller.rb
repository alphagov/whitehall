class DocumentsController < ApplicationController
  def index
    @policies = Policy.published
    @publications = Publication.published
    @news_articles = NewsArticle.published
  end

  def show
    unless @document = Document.published_as(params[:id])
      render text: "Not found", status: :not_found
    end
  end
end