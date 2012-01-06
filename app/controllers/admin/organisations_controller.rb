class Admin::OrganisationsController < Admin::BaseController
  before_filter :load_organisation, only: [:edit, :update]
  before_filter :load_news_articles, only: [:edit, :update]

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
    @news_articles = NewsArticle.published.in_organisation(@organisation).order("updated_at desc")
  end
end