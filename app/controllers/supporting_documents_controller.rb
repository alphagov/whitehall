class SupportingDocumentsController < ApplicationController
  before_filter :find_policy
  before_filter :find_supporting_document, only: [:show]

  def index
    @supporting_documents = @policy.supporting_documents
  end

  def show
    @document = @supporting_document
    @related_publications = Publication.published.related_to(@policy)
    @related_consultations = Consultation.published.related_to(@policy)
    @related_news_articles = NewsArticle.published.related_to(@policy)
    @related_speeches = Speech.published.related_to(@policy)
    render template: "policies/show"
  end

  private

  def find_policy
    unless @policy = Policy.published_as(params[:policy_id])
      render text: "Not found", status: :not_found
    end
  end

  def find_supporting_document
    @supporting_document = @policy.supporting_documents.find(params[:id])
  end
end