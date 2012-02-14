class HomeController < PublicFacingController
  def show
    @documents = Document.published.by_published_at.limit(15)
  end
end