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
end
