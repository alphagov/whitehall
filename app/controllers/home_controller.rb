class HomeController < PublicFacingController
  layout 'frontend'

  def feed
    @recently_updated = Edition.published.in_reverse_chronological_order.includes(:document, :organisations).limit(10)
  end

  def sunset
    render layout: 'home'
  end
end
