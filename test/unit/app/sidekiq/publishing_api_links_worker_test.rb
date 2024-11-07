require "test_helper"

class PublishingApiLinksWorkerTest < ActiveSupport::TestCase
  test "#perform sends a patch links request to Publishing API" do
    publication = create(:publication)
    Services.publishing_api
      .expects(:patch_links)
      .with(publication.content_id,
            links: PublishingApiPresenters.presenter_for(publication).links,
            bulk_publishing: true)

    PublishingApiLinksWorker.new.perform(publication.id)
  end
end
