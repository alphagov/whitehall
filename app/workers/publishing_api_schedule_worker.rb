class PublishingApiScheduleWorker
  include Sidekiq::Worker

  attr_accessor :model, :locale

  def perform(model_name, id, locale=I18n.default_locale.to_s)
    @model = class_for(model_name).find(id)
    return unless @model
    @locale = locale

    # Coming soon needs to be sent first, as currently content-store deletes
    # an intent when a content item is created for that path.
    publish_coming_soon unless @model.document.published?
    publish_publish_intent
  end

private

  def publish_publish_intent
    presenter = PublishingApiPresenters.publish_intent_for(model)
    I18n.with_locale(locale) do
      Whitehall.publishing_api_client.put_intent(
        presenter.base_path,
        presenter.as_json)
    end
  end

  def publish_coming_soon
    presenter = PublishingApiPresenters.coming_soon_for(model)
    I18n.with_locale(locale) do
      Whitehall.publishing_api_client.put_content_item(
        presenter.base_path,
        presenter.as_json)
    end
  end

  def class_for(model_name)
    model_name.constantize
  end
end
