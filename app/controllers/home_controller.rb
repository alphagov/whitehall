class HomeController < PublicFacingController
  def show
    @documents = Edition.published.by_published_at.limit(16)
  end
end