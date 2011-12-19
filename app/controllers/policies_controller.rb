class PoliciesController < DocumentsController
  def index
    @policies = Policy.published.by_published_at
  end

  def show
    @policy = @document
    @related_publications = Publication.published.related_to(@policy)
    @related_consultations = Consultation.published.related_to(@policy)
    @related_news_articles = NewsArticle.published.related_to(@policy)
    @related_speeches = Speech.published.related_to(@policy)
    @countries = @policy.countries
    @recently_changed_documents = Document.published.related_to(@policy).by_published_at
  end

  private

  def document_class
    Policy
  end
end