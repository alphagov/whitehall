class Admin::CountriesController < Admin::BaseController
  before_filter :load_country, only: [:edit, :update]
  before_filter :load_news_articles, only: [:edit, :update]

  def index
    @countries = Country.all
  end

  def edit
  end

  def update
    if @country.update_attributes(params[:country])
      redirect_to admin_countries_path, notice: "Country updated successfully"
    else
      render action: :edit
    end
  end

  private

  def load_country
    @country = Country.find(params[:id])
  end

  def load_news_articles
    @news_articles = NewsArticle.published.in_country(@country).by_first_published_at
  end
end