class PublishingApiWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(model_name,
              id,
              update_type = nil,
              locale = I18n.default_locale.to_s,
              bulk_publishing = false)

    model = class_for(model_name).unscoped.find_by(id: id)
    return if model.nil?

    if model.is_a?(Edition)
      check_if_locked_document(model.content_id)
    end

    presenter = PublishingApiPresenters.presenter_for(model, update_type: update_type)

    I18n.with_locale(locale) do
      begin
        send_item(presenter, locale, bulk_publishing)
      rescue GdsApi::HTTPClientError => e
        handle_client_error(e)
      end
    end
  end

private

  def class_for(model_name)
    model_name.constantize
  end

  def send_item(payload, locale, bulk_publishing = false)
    save_draft(payload, bulk_publishing)
    Services.publishing_api.patch_links(
      payload.content_id,
      links: payload.links,
      bulk_publishing: bulk_publishing
    )
    Services.publishing_api.publish(payload.content_id, nil, locale: locale)
  end

  def save_draft(payload, bulk_publishing)
    content = payload.content

    content.merge!(bulk_publishing: true) if bulk_publishing

    Services.publishing_api.put_content(payload.content_id, content)
  end

  def handle_client_error(error)
    explanation = "The error code indicates that retrying this request will not help. This job is being aborted and will not be retried."
    GovukError.notify(error, extra: { explanation: explanation })
  end

  def check_if_locked_document(content_id)
    document = Document.find_by(content_id: content_id)
    return unless document.present?

    if document.locked?
      raise RuntimeError, "Cannot send a locked document to the Publishing API"
    end
  end
end
