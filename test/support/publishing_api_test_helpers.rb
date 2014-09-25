require "gds_api/test_helpers/publishing_api"

module PublishingApiTestHelpers
  include GdsApi::TestHelpers::PublishingApi

  def stub_publishing_api_registration_for(editions)
    Array(editions).each do |edition|
      registerable_edition = RegisterableEdition.new(edition)
      expected_attributes = registerable_edition.attributes_for_publishing_api.merge(
        public_updated_at: Time.zone.now.iso8601
      )
      stub_publishing_api_put_item(registerable_edition.base_path, expected_attributes)
    end
  end
end
