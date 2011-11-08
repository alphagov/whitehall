class CountriesController < ApplicationController
  def index
    @countries = Country.all
  end
end