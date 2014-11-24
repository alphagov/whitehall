class EmbassiesController < ApplicationController
  def index
    @embassies_by_location = WorldLocation.geographical.order(:slug).map do |location|
      Embassy.new(location)
    end
  end
end
