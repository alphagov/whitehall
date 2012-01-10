class Admin::OrganisationsController < Admin::BaseController
  before_filter :load_organisation, only: [:edit, :update]
  before_filter :load_news_articles, only: [:edit, :update]
  before_filter :default_arrays_of_ids_to_empty, only: [:update]

  def index
    @organisations = Organisation.all
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to admin_organisations_path
    else
      render action: "new"
    end
  end

  def edit
  end

  def update
    if @organisation.update_attributes(params[:organisation])
      redirect_to admin_organisations_path
    else
      render action: "edit"
    end
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end

  def load_news_articles
    @news_articles = NewsArticle.published.in_organisation(@organisation).by_published_at
  end

  private

  def default_arrays_of_ids_to_empty
    params[:organisation][:policy_area_ids] ||= []
    params[:organisation][:parent_organisation_ids] ||= []
  end
end