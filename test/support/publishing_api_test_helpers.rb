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
      Whitehall.publishing_api_v2_client.expects(:put_content)
        .with(edition.content_id,
          has_entries(content_id: edition.content_id, update_type: 'major',
            publishing_app: 'whitehall', rendering_app: 'whitehall-frontend'))
      Whitehall.publishing_api_v2_client.expects(:publish)
        .with(edition.content_id,
          has_entries(update_type: 'major'))
    end
  end

  def expect_republishing(*editions)
    editions.each do |edition|
      Whitehall.publishing_api_v2_client.expects(:put_content)
        .with(edition.content_id,
          has_entries(content_id: edition.content_id, update_type: 'republish',
            publishing_app: 'whitehall', rendering_app: 'whitehall-frontend'))
      Whitehall.publishing_api_v2_client.expects(:publish)
        .with(edition.content_id,
          has_entries(update_type: 'republish'))
    end
  end

  def expect_no_republishing(*editions)
    editions.each do |edition|
      Whitehall.publishing_api_v2_client.expects(:put_content)
        .with(content_id: edition.content_id).never
    end
  end
end
