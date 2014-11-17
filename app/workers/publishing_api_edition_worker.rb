class PublishingApiEditionWorker
  include Sidekiq::Worker

  def perform(edition_id, options = {})
    edition = Edition.find(edition_id)
    if edition.is_a?(CaseStudy)
      presenter = PublishingApiPresenters::CaseStudy.new(edition)
    else
      presenter = PublishingApiPresenters::Edition.new(edition)
    end

    Whitehall.publishing_api_client.put_content_item(
      presenter.base_path,
      presenter.as_json
    )
  end
end
