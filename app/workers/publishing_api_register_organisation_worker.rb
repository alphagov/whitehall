class PublishingApiRegisterOrganisationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :publishing_api

  def perform(organisation_id, options = {})
    organisation = Organisation.find(organisation_id)

    if organisation.present?
      registerable_org = organisation
      Whitehall.publishing_api_client.put_content_item(
        registerable_org.base_path,
        registerable_org.attributes_for_publishing_api
      )
    end
  end

end
