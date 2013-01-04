class DetailedGuidePresenter < Draper::Base
  include EditionPresenterHelper

  decorates :detailed_guide
end
