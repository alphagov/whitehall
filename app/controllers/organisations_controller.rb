class OrganisationsController < PublicFacingController
  before_filter :load_organisation,
    only: [:show, :about, :contact_details, :announcements, :consultations,
           :ministers, :management_team, :policies, :publications,
           :agencies_and_partners]

  def index
    @organisations_by_type = Organisation.in_listing_order.group_by(&:organisation_type)
  end

  def alphabetical
    @organisations = Organisation.ordered_by_name_ignoring_prefix
  end

  def show
    @recently_updated = @organisation.published_editions.by_published_at.limit(4)
    @news_articles = NewsArticle.published.in_organisation(@organisation)
    @primary_featured_editions = @organisation.featured_editions.limit(3)
    @secondary_featured_editions = @organisation.featured_editions.limit(3).offset(3)
    @top_ministerial_role = @organisation.top_ministerial_role && RolePresenter.decorate(@organisation.top_ministerial_role)
    @top_civil_servant = @organisation.top_civil_servant && RolePresenter.decorate(@organisation.top_civil_servant)
  end

  def about
    @corporate_publications = @organisation.corporate_publications.published
  end

  def agencies_and_partners
  end

  def contact_details
  end

  def announcements
    @announcements = Announcement.by_first_published_at(NewsArticle.in_organisation(@organisation).published + @organisation.published_speeches)
  end

  def consultations
    @consultations = Consultation.in_organisation(@organisation).published.by_published_at
  end

  def ministers
    @ministerial_roles = @organisation.ministerial_roles.order("organisation_roles.ordering").map do |role|
      RolePresenter.new(role)
    end
  end

  def publications
    @publications = Publication.published.in_organisation(@organisation).order("publication_date DESC")
  end

  def management_team
  end

  def policies
    @policies = Policy.published.in_organisation(@organisation)
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end
end
