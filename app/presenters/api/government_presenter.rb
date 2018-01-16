class Api::GovernmentPresenter < Api::BasePresenter
  def as_json(_options = {})
    {
      id: context.api_government_url(model.slug),
      title: model.name,
      slug: model.slug,
      details: {
        start_date: model.start_date,
        end_date: model.end_date,
      },
    }
  end

  def links
    [
      [context.api_government_url(model.slug), { 'rel' => 'self' }]
    ]
  end
end
