class Api::LicenceActivitiesPresenter < Api::BasePresenter
  def as_json(_options = {})
    {
      id: model.id,
      title: model.title,
      sectors: model.sectors,
    }
  end
end
