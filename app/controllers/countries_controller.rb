class CountriesController < PublicFacingController
  before_filter :load_country, only: [:show, :about]

  def index
    @countries = Country.all
    @featured_countries = Country.featured
  end

  def show
    @international_priorities = InternationalPriority.published.in_country(@country).by_published_at
    @news_articles = NewsArticle.published.in_country(@country).by_first_published_at
    @policies = Policy.published.in_country(@country).by_published_at
    @speeches = Speech.published.in_country(@country).by_first_published_at
    @publications = Publication.published.in_country(@country).by_published_at
  end

  def about
  end

  private

  def load_country
    @country = Country.find(params[:id])
  end
end
