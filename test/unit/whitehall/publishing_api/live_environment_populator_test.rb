require 'whitehall/publishing_api'

module Whitehall
  class PublishingApi
    class LiveEnvironmentPopulatorTest < ActiveSupport::TestCase
      test "default instance uses the default items and #send_to_publishing_api as sender" do
        logger = stub("logger", info: nil)
        items = [stub("item")]
        LiveEnvironmentPopulator.stubs(:default_items).returns(items)
        LiveEnvironmentPopulator.expects(:send_to_publishing_api).with(items.first)

        LiveEnvironmentPopulator.new(logger: logger).call
      end

      test ".send_to_publishing_api calls publish_async with the item" do
        item = stub("item")
        PublishingApi.expects(:publish_async).with(item, 'bulk_update', 'bulk_republishing')
        LiveEnvironmentPopulator.send_to_publishing_api(item)
      end

      test "default_items defaults to an enumeration of all published items which can be sent to publishing api" do
        organisation = create(:organisation)

        expected_values = [
          create(:published_edition),
          create(:ministerial_role, organisations: [organisation]),
          organisation,
          create(:person),
          create(:world_location),
          create(:worldwide_organisation)
        ]

        assert_equal expected_values, LiveEnvironmentPopulator.default_items.to_a
      end

      test "default_items has only the published edition of a document" do
        published_edition = create(:published_edition)
        latest_edition = create(:draft_edition, document: published_edition.document)

        assert_equal [published_edition], LiveEnvironmentPopulator.default_items.to_a
      end
    end
  end
end
