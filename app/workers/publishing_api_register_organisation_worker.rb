class PublishingApiRegisterOrganisationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :publishing_api

  def perform(organisation_id, options = {})
    organisation = Organisation.find(organisation_id)

    Whitehall.publishing_api_client.put_content_item(
      organisation.base_path,
      organisation.attributes_for_publishing_api
    )
  end

end
