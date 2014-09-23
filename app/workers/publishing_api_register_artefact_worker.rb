class PublishingApiRegisterArtefactWorker
  include Sidekiq::Worker
  sidekiq_options queue: :publishing_api

  def perform(edition_id, options = {})
    edition = Edition.find(edition_id)

    if edition.present?
      registerable_edition = RegisterableEdition.new(edition)
      Whitehall.publishing_api_client.put_content_item(
        registerable_edition.base_path,
        registerable_edition.attributes_for_publishing_api
      )
    end
  end

end
