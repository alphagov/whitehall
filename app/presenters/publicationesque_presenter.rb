class PublicationesquePresenter < Draper::Base
  include EditionPresenterHelper

  decorates :publicationesque
end
