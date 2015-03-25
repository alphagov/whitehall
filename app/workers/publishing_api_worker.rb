class PublishingApiWorker
  include Sidekiq::Worker

  def perform(model_name, id, update_type = nil, locale=I18n.default_locale.to_s)
    return unless model = class_for(model_name).find_by(id: id)

    presenter = PublishingApiPresenters.presenter_for(model, update_type: update_type)

    I18n.with_locale(locale) do
      send_item(presenter.base_path, presenter.as_json)
    end
  end

  private

  def class_for(model_name)
    model_name.constantize
  end

  def send_item(base_path, content)
    Whitehall.publishing_api_client.put_content_item(base_path, content)
  end
end
