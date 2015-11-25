class PublishingApiWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(model_name, id, update_type = nil, locale=I18n.default_locale.to_s)
    return unless model = class_for(model_name).find_by(id: id)

    presenter = PublishingApiPresenters.presenter_for(model, update_type: update_type)

    I18n.with_locale(locale) do
      payload = presenter.as_json
      send_item(payload, locale)

      if model.is_a?(::Unpublishing)
        # Unpublishings will be mirrored to the draft content-store, but we want
        # it to have the now-current draft edition
        save_draft_of_unpublished_edition(model)
      end
    end
  end

  private

  def class_for(model_name)
    model_name.constantize
  end

  def send_item(payload, locale = payload[:locale])
    save_draft(payload)
    Whitehall.publishing_api_v2_client.publish(payload[:content_id], locale: locale, update_type: payload[:update_type])
  end

  def save_draft(payload)
    Whitehall.publishing_api_v2_client.put_content(payload[:content_id], payload.except(:links))
    Whitehall.publishing_api_v2_client.put_links(payload[:content_id], payload.slice(:links)) if payload[:links]
  end

  def save_draft_of_unpublished_edition(unpublishing)
    if draft = unpublishing.edition
      Whitehall::PublishingApi.save_draft_async(draft)
    end
  end
end
