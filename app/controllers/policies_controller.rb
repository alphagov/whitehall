class PoliciesController < DocumentsController
  def index
    @policies = Policy.published.by_publication_date
  end

  def show
    @related_publications = Publication.published.related_to(@document)
    @related_consultations = Consultation.published.related_to(@document)
    @related_news_articles = NewsArticle.published.related_to(@document)
  end

  private

  def document_class
    Policy
  end
end