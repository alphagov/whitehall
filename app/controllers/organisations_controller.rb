class OrganisationsController < PublicFacingController
  before_filter :load_organisation, only: [:show, :about, :contact_details, :announcements, :consultations,
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
    @speeches = @organisation.published_speeches.sort_by(&:first_published_at).reverse.take(3)
    @corporate_publications = @organisation.corporate_publications.published
    @featured_news_articles = @organisation.featured_news_articles
  end

  def about
  end

  def contact_details
  end

  def announcements
    @announcements = (NewsArticle.in_organisation(@organisation).published + @organisation.published_speeches).sort_by!{|a| a.first_published_at }.reverse
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