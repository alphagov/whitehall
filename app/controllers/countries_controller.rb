class CountriesController < ApplicationController
  def index
    @countries = Country.all
  end

  def show
    @country = Country.find(params[:id])
    @news_articles = NewsArticle.published.in_country(@country).by_published_at
    @policies = Policy.published.in_country(@country).by_published_at
    @speeches = Speech.published.in_country(@country).by_published_at
    @publications = Publication.published.in_country(@country).by_published_at
  end
end