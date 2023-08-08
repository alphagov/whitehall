module PublishingApiPresenters
  class << self
    def presenter_for(model, options = {})
      model.publishing_api_presenter.new(model, **options)
    end
  end
end
