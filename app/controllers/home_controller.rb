class HomeController < PublicFacingController
  def show
    @recently_updated = Edition.published.by_published_at.includes(:document, :organisations).limit(10)
  end

  def sunset
  end

  def tour
  end

end
