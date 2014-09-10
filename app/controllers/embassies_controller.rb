class EmbassiesController < ApplicationController
  def index
    @embassies_by_location = WorldLocation.order(:slug).map do |location|
      ConsularServicesLocation.new(location)
    end
  end
end
