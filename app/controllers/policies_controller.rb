class PoliciesController < DocumentsController
  def index
    @policies = Policy.published.by_publication_date
  end

  def show
    @policy = @document
    @related_publications = Publication.published.related_to(@policy)
    @related_consultations = Consultation.published.related_to(@policy)
    @related_news_articles = NewsArticle.published.related_to(@policy)
    @related_speeches = Speech.published.related_to(@policy)
  end

  private

  def document_class
    Policy
  end
end