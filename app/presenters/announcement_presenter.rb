class AnnouncementPresenter < Draper::Base
  include EditionPresenterHelper

  decorates :announcement
end
