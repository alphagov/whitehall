class PublishingApiWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(model_name, id, update_type = nil, locale=I18n.default_locale.to_s)
    model = class_for(model_name).unscoped.find_by(id: id)
    return if model.nil?

    presenter = PublishingApiPresenters.presenter_for(model, update_type: update_type)

    I18n.with_locale(locale) do
      begin
        send_item(presenter, locale)
      rescue GdsApi::HTTPClientError => e
        handle_client_error(e)
      end

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

  def send_item(payload, locale)
    save_draft(payload)
    Whitehall.publishing_api_v2_client.publish(payload.content_id, payload.update_type, locale: locale)
    Whitehall.publishing_api_v2_client.patch_links(payload.content_id, links: payload.links)
  end

  def save_draft(payload)
    Whitehall.publishing_api_v2_client.put_content(payload.content_id, payload.content)
  end

  def save_draft_of_unpublished_edition(unpublishing)
    if draft = unpublishing.edition
      Whitehall::PublishingApi.save_draft_async(draft)
    end
  end

  def handle_client_error(error)
    explanation = "The error code indicates that retrying this request will not help. This job is being aborted and will not be retried."
    Airbrake.notify_or_ignore(error, parameters: { explanation: explanation })
  end
end
