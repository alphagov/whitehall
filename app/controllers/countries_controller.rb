class CountriesController < ApplicationController
  def index
    @countries = Country.all
  end

  def show
    @country = Country.find(params[:id])
    @news_articles = NewsArticle.published.in_country(@country)
  end
end