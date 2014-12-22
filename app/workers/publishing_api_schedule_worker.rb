class PublishingApiScheduleWorker
  include Sidekiq::Worker

  attr_accessor :edition, :locale

  def perform(id, locale)
    @edition = Edition.find(id)
    @locale = locale

    # Coming soon needs to be sent first, as currently content-store deletes
    # an intent when a content item is created for that path.
    publish_coming_soon unless edition.document.published?
    publish_publish_intent
  end

private

  def publish_publish_intent
    presenter = PublishingApiPresenters.publish_intent_for(edition)
    I18n.with_locale(locale) do
      Whitehall.publishing_api_client.put_intent(
        presenter.base_path,
        presenter.as_json)
    end
  end

  def publish_coming_soon
    presenter = PublishingApiPresenters.coming_soon_for(edition)
    I18n.with_locale(locale) do
      Whitehall.publishing_api_client.put_content_item(
        presenter.base_path,
        presenter.as_json)
    end
  end
end
