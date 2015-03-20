require "gds_api/test_helpers/publishing_api"

module PublishingApiTestHelpers
  include GdsApi::TestHelpers::PublishingApi

  def stub_publishing_api_registration_for(editions)
    Array(editions).each do |edition|
      presenter = PublishingApiPresenters::Edition.new(edition)
      expected_attributes = presenter.as_json.merge(
        public_updated_at: Time.zone.now.iso8601
      )
      stub_publishing_api_put_item(presenter.base_path, expected_attributes)
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
