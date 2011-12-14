class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods

  protect_from_forgery

  layout 'website'

  private

  def load_published_documents_in_scope(&block)
    @policies = yield(Policy.published)
    @publications = yield(Publication.published)
    @news_articles = yield(NewsArticle.published)
    @consultations = yield(Consultation.published)
  end

  def skip_slimmer
    response.headers[Slimmer::SKIP_HEADER] = "true"
  end
end