class OrganisationsController < PublicFacingController

  before_filter :load_organisation, only: [:show, :about]

  def index
    @organisations = Organisation.ordered_by_name_ignoring_prefix
  end

  def show
    load_published_documents_in_scope { |scope| scope.in_organisation(@organisation) }
    @speeches = @organisation.ministerial_roles.map { |mr| mr.speeches.published }.flatten.uniq
    @corporate_publications = @organisation.corporate_publications.published
    @featured_news_articles = @organisation.featured_news_articles
  end

  def about
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end
end