require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/publishing_api_v2"

module PublishingApiTestHelpers
  include GdsApi::TestHelpers::PublishingApiV2

  def stub_publishing_api_registration_for(editions)
    Array(editions).each do |edition|
      presenter = PublishingApiPresenters::Edition.new(edition)
      stub_publishing_api_put_content_links_and_publish(presenter.as_json)
    end
  end

  def expect_publishing(*editions)
    editions.each do |edition|
      Whitehall.publishing_api_client.expects(:put_content_item)
        .with(Whitehall.url_maker.public_document_path(edition),
          has_entries(content_id: edition.content_id, update_type: 'major',
            publishing_app: 'whitehall', rendering_app: 'whitehall-frontend'))
    end
  end

  def expect_republishing(*editions)
    editions.each do |edition|
      Whitehall.publishing_api_client.expects(:put_content_item)
        .with(Whitehall.url_maker.public_document_path(edition),
          has_entries(content_id: edition.content_id, update_type: 'republish',
            publishing_app: 'whitehall', rendering_app: 'whitehall-frontend'))
    end
  end

  def expect_no_republishing(*editions)
    editions.each do |edition|
      Whitehall.publishing_api_client.expects(:put_content_item)
        .with(Whitehall.url_maker.public_document_path(edition)).never
    end
  end
end
