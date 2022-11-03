class PublishingApiWorker < WorkerBase
  sidekiq_options queue: "publishing_api"

  def perform(model_name,
              id,
              update_type = nil,
              locale = I18n.default_locale.to_s,
              bulk_publishing = false)

    model = class_for(model_name).unscoped.find_by(id:)
    return if model.nil?

    presenter = PublishingApiPresenters.presenter_for(model, update_type:)

    I18n.with_locale(locale) do
      send_item(presenter, locale, bulk_publishing)
    rescue GdsApi::HTTPConflict => e
      # The Publishing API sometimes returns: Cannot publish an
      # already published edition. Ideally we'd avoid this error,
      # but for now, just avoid recording it in Sentry, as it's
      # not actionable.
      logger.error "PublishingApiWorker: HTTPConflict: #{e.message}"
    rescue GdsApi::HTTPClientError => e
      handle_client_error(e)
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
      bulk_publishing:,
    )
    Services.publishing_api.publish(payload.content_id, nil, locale:)
  end

  def save_draft(payload, bulk_publishing)
    content = payload.content

    content.merge!(bulk_publishing: true) if bulk_publishing

    Services.publishing_api.put_content(payload.content_id, content)
  end

  def handle_client_error(error)
    explanation = "The error code indicates that retrying this request will not help. This job is being aborted and will not be retried."
    GovukError.notify(error, extra: { explanation: })
  end
end
