class EmbassiesController < ApplicationController
  def index
    @embassies_by_location = WorldLocation.order(:slug).map do |location|
      Embassy.new(location)
    end
  end
end
