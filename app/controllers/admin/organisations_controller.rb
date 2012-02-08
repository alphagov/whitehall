class Admin::OrganisationsController < Admin::BaseController
  before_filter :load_organisation, only: [:edit, :update]
  before_filter :load_news_articles, only: [:edit, :update]
  before_filter :default_arrays_of_ids_to_empty, only: [:update]
  before_filter :destroy_blank_phone_numbers, only: [:create, :update]

  def index
    @organisations = Organisation.all
  end

  def new
    @organisation = Organisation.new
    @ministerial_organisation_roles = []
  end

  def create
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to admin_organisations_path
    else
      @ministerial_organisation_roles = []
      render action: "new"
    end
  end

  def edit
    load_organisation_ministerial_roles
  end

  def update
    if @organisation.update_attributes(params[:organisation])
      redirect_to admin_organisations_path
    else
      load_organisation_ministerial_roles
      render action: "edit"
    end
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end

  def load_news_articles
    @news_articles = NewsArticle.published.in_organisation(@organisation).by_first_published_at
  end

  def load_organisation_ministerial_roles
    @ministerial_organisation_roles = @organisation.organisation_roles.joins(:role).where("roles.type = 'MinisterialRole'").order(:ordering)
  end

  private

  def default_arrays_of_ids_to_empty
    params[:organisation][:policy_area_ids] ||= []
    params[:organisation][:parent_organisation_ids] ||= []
  end

  def destroy_blank_phone_numbers
    if params[:organisation][:contacts_attributes]
      params[:organisation][:contacts_attributes].each do |index, contact|
        if contact && contact[:contact_numbers_attributes]
          contact[:contact_numbers_attributes].each do |key, number|
            if number[:label].blank? && number[:number].blank?
              number[:_destroy] = "1"
            end
          end
        end
      end
    end
  end
end