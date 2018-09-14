class PublishingApiWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(model_name, id, update_type = nil, locale = I18n.default_locale.to_s)
    model = class_for(model_name).unscoped.find_by(id: id)
    return if model.nil?

    presenter = PublishingApiPresenters.presenter_for(model, update_type: update_type)

    I18n.with_locale(locale) do
      begin
        send_item(presenter, locale)
      rescue GdsApi::HTTPClientError => e
        handle_client_error(e)
      end
    end
  end

private

  def class_for(model_name)
    model_name.constantize
  end

  def send_item(payload, locale)
    save_draft(payload)
    Services.publishing_api.patch_links(payload.content_id, links: payload.links)
    Services.publishing_api.publish(payload.content_id, nil, locale: locale)
  end

  def save_draft(payload)
    Services.publishing_api.put_content(payload.content_id, payload.content)
  end

  def handle_client_error(error)
    explanation = "The error code indicates that retrying this request will not help. This job is being aborted and will not be retried."
    GovukError.notify(error, extra: { explanation: explanation })
  end
end
