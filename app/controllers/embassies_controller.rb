class EmbassiesController < ApplicationController
  def index
    @embassies_by_location =
      WorldLocation.geographical.order(:slug).map { |location|
        # We don't want to show the UK on the embassies page.
        next if location.name.in?(["United Kingdom"])

        EmbassyPresenter.new(Embassy.new(location))
      }.reject(&:blank?)

    set_meta_description("Contact details of British embassies, consulates, and high commissions around the world.")
  end
end
