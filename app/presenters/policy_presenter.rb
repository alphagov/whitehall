class PolicyPresenter < Draper::Base
  include EditionPresenterHelper

  decorates :policy
end
