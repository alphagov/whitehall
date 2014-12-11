class PublishingApiScheduleWorker
  include Sidekiq::Worker

  def perform(model_name, id, locale=I18n.default_locale.to_s)
    model = class_for(model_name).find_by_id(id)
    return unless model

    # Coming soon needs to be sent first, as currently content-store deletes
    # an intent when a content item is created for that path.
    publish_coming_soon(model, locale) if model.document.published_edition.nil?
    publish_intent(model, locale)
  end

  def publish_intent(model, locale)
    presenter = PublishingApiPresenters.intent_for(model)
    I18n.with_locale(locale) do
      Whitehall.publishing_api_client.put_intent(
        presenter.base_path,
        presenter.as_json)
    end
  end

  def publish_coming_soon(model, locale)
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
