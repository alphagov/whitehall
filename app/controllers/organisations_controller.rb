class OrganisationsController < PublicFacingController
  before_filter :load_organisation, only: [:show, :about, :contact_details, :news, :consultations,
                                           :ministers, :board_members, :policies, :publications]

  def index
    @organisations_by_type = Organisation.in_listing_order.group_by(&:organisation_type)
  end

  def alphabetical
    @organisations = Organisation.ordered_by_name_ignoring_prefix
  end

  def show
    @policies = Policy.published.in_organisation(@organisation).by_published_at.limit(3)
    @publications = Publication.published.in_organisation(@organisation).order("publication_date DESC").limit(3)
    @news_articles = NewsArticle.published.in_organisation(@organisation)
    @consultations = Consultation.published.by_published_at.in_organisation(@organisation).limit(3)
    @speeches = @organisation.ministerial_roles.map { |mr| mr.speeches.published }.flatten.uniq
    @corporate_publications = @organisation.corporate_publications.published
    @featured_news_articles = @organisation.featured_news_articles
  end

  def about
  end

  def contact_details
  end

  def news
    @news_articles = NewsArticle.in_organisation(@organisation).published.by_published_at
  end

  def consultations
    @consultations = Consultation.in_organisation(@organisation).published.by_published_at
  end

  def ministers
  end

  def publications
    @publications = Publication.published.in_organisation(@organisation).order("publication_date DESC")
  end

  def board_members
  end

  def policies
    @policies = Policy.published.in_organisation(@organisation)
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end
end