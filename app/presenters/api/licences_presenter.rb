class Api::LicencesPresenter < Api::BasePresenter
  def as_json(_options = {})
    {
      title: model.title,
      link: model.link,
      sectors: model.sectors,
      activities: model.activities,
    }
  end
end
