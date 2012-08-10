class AnnouncementsController < PublicFacingController

  def index
    @announced = AnnouncementPresenter.new
    @results = @announced.homepage
  end
end
