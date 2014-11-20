class PublishingApiOrganisationWorker
  include Sidekiq::Worker

  def perform(organisation_id, options = {})
    organisation = Organisation.find(organisation_id)
    presenter = PublishingApiPresenters.presenter_for(organisation)

    Whitehall.publishing_api_client.put_content_item(
      presenter.base_path,
      presenter.as_json
    )
  end
end
