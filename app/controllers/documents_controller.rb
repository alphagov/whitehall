class DocumentsController < ApplicationController
  def index
    @policies = Policy.published
    @publications = Publication.published
    @news_articles = NewsArticle.published
    @consultations = Consultation.published
    @speeches = Speech.published
  end

  def show
    unless @document = document_class.published_as(params[:id])
      render text: "Not found", status: :not_found
    end
  end

  private

  def document_class
    Document
  end

end