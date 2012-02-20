class AnnouncementsController < PublicFacingController

  def index
    @announced = AnnouncementPresenter.new
  end
end