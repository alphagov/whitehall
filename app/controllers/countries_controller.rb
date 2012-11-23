class CountriesController < PublicFacingController
  before_filter :load_country, only: [:show, :about]

  def index
    @countries = Country.all
    @featured_country = Country.featured.first
  end

  def show
    @international_priorities = InternationalPriority.published.in_country(@country).in_reverse_chronological_order
    @news_articles = NewsArticle.published.in_country(@country).in_reverse_chronological_order
    @policies = Policy.published.in_country(@country).in_reverse_chronological_order
    @speeches = Speech.published.in_country(@country).in_reverse_chronological_order
    @publications = Publication.published.in_country(@country).in_reverse_chronological_order

    @featured_news_articles = @country.featured_news_articles.in_reverse_chronological_order.limit(3)
  end

  def about
  end

  private

  def load_country
    @country = Country.find(params[:id])
  end
end
