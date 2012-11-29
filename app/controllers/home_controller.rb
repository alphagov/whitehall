class HomeController < PublicFacingController
  layout 'frontend'

  def feed
    @recently_updated = Edition.published.in_reverse_chronological_order.includes(:document, :organisations).limit(10)
  end

  def sunset
    render layout: 'home'
  end

  def how_government_works
    @policy_count = Policy.published.count
  end
end
