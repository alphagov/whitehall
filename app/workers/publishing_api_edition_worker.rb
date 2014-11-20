# FIXME: This will be redundant once the existing jobs have been worked off
class PublishingApiEditionWorker
  include Sidekiq::Worker

  def perform(edition_id, options = {})
    edition = Edition.find(edition_id)
    presenter = PublishingApiPresenters.presenter_for(edition)

    Whitehall.publishing_api_client.put_content_item(
      presenter.base_path,
      presenter.as_json
    )
  end
end
