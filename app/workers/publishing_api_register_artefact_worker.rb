class PublishingApiRegisterArtefactWorker
  include Sidekiq::Worker
  sidekiq_options queue: :publishing_api

  def perform(edition_id, options = {})
    edition = Edition.find(edition_id)
    presenter = PublishingApiPresenters::Edition.new(edition)

    Whitehall.publishing_api_client.put_content_item(
      presenter.base_path,
      presenter.as_json
    )
  end
end
