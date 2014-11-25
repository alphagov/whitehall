class PublishingApiWorker
  include Sidekiq::Worker

  def perform(model_name, id, options = {})
    model = class_for(model_name).find(id)
    presenter = PublishingApiPresenters.presenter_for(model, options)

    Whitehall.publishing_api_client.put_content_item(
      presenter.base_path,
      presenter.as_json
    )
  end

  def class_for(model_name)
    model_name.constantize
  end
end
