
class EmbassiesController < ApplicationController
  def index
    @embassies_by_location =
      WorldLocation.geographical.order(:slug).map { |location|
        # We don't want to show the UK on the embassies page.
        next if location.name.in?(["United Kingdom"])
        Embassy.new(location)
      }.reject(&:blank?)
  end
end
