class OrganisationsController < PublicFacingController
  before_filter :load_organisation,
    only: [:show, :about, :contact_details, :consultations,
           :ministers, :management_team, :policies,
           :agencies_and_partners, :chiefs_of_staff]

  def index
    @organisations_by_type = Organisation.includes(:organisation_type, :corporate_information_pages).in_listing_order.group_by(&:organisation_type)
  end

  def alphabetical
    @organisations = Organisation.ordered_by_name_ignoring_prefix
  end

  def show
    @recently_updated = @organisation.published_editions.by_published_at.limit(4)
    if @organisation.live?
      @news_articles = NewsArticle.published.in_organisation(@organisation)
      @primary_featured_editions = @organisation.featured_editions.limit(3)
      @secondary_featured_editions = @organisation.featured_editions.limit(3).offset(3)
      @top_ministerial_role = @organisation.top_ministerial_role && RolePresenter.decorate(@organisation.top_ministerial_role)
      @top_civil_servant = @organisation.top_civil_servant && RolePresenter.decorate(@organisation.top_civil_servant)
      @top_military_role = @organisation.top_military_role && RolePresenter.decorate(@organisation.top_military_role)
    else
      render action: 'external'
    end
  end

  def about
    @corporate_publications = @organisation.corporate_publications.published
  end

  def agencies_and_partners
  end

  def contact_details
  end

  def consultations
    @consultations = Consultation.in_organisation(@organisation).published.by_published_at
  end

  def ministers
    @ministerial_roles = @organisation.ministerial_roles.order("organisation_roles.ordering").map do |role|
      RolePresenter.new(role)
    end
  end

  def management_team
  end

  def chiefs_of_staff
  end

  def policies
    @policies = Policy.published.in_organisation(@organisation)
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end
end
