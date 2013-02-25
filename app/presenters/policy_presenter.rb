class PolicyPresenter < Draper::Base
  include EditionPresenterHelper

  decorates :policy

  def as_hash
    super.merge({
      topics: model.topics.map(&:name).join(", ").html_safe
    })
  end
end
