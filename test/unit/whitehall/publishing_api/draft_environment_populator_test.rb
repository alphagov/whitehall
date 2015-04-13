require 'whitehall/publishing_api'

module Whitehall
  class PublishingApi
    class DraftEnvironmentPopulatorTest < ActiveSupport::TestCase

      test "calls PublishingApi.publish_draft_async for all editions" do
        all_editions = [stub("edition")]
        PublishingApi.expects(:publish_draft_async).with(all_editions.first, 'bulk_draft_update', 'bulk_republishing')
        DraftEnvironmentPopulator.new(draft_items: all_editions).call
      end

      test "draft_items defaults to an enumeration of all items which can be sent to publishing api" do
        organisation = create(:organisation)

        expected_values = [
          create(:published_edition),
          create(:draft_edition),
          create(:ministerial_role, organisations: [organisation]),
          organisation,
          create(:person),
          create(:world_location),
          create(:worldwide_organisation)
        ]

        assert_equal expected_values, DraftEnvironmentPopulator.new.draft_items.to_a
      end

      test "default draft_items has only the latest edition of a document" do
        published_edition = create(:published_edition)
        latest_edition = create(:draft_edition, document: published_edition.document)

        assert_equal [latest_edition], DraftEnvironmentPopulator.new.draft_items.to_a
      end
    end
  end
end
