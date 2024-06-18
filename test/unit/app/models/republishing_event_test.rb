require "test_helper"

class RepublishingEventTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "content_type" do
    context "for an `all_by_type` bulk republishing event" do
      test "should be valid with a content type" do
        event = build(:republishing_event, :bulk, bulk_content_type: "all_by_type", content_type: "a content type")
        assert event.valid?
      end

      test "should be invalid without a content type" do
        event = build(:republishing_event, :bulk, bulk_content_type: "all_by_type", content_type: nil)
        assert_not event.valid?
      end
    end

    context "for any other republishing event" do
      test "must not be present" do
        bulk_event = build(:republishing_event, :bulk, bulk_content_type: "all_documents", content_type: "all documents")
        assert_not bulk_event.valid?

        non_bulk_event = build(:republishing_event, content_type: "all documents")
        assert_not non_bulk_event.valid?
      end
    end
  end

  describe "organisation_id" do
    context "for an `all_documents_by_organisation` bulk republishing event" do
      test "should be valid with an organisation ID" do
        event = build(:republishing_event, :bulk, bulk_content_type: "all_documents_by_organisation", organisation_id: "1234")
        assert event.valid?
      end

      test "should be invalid without a content type" do
        event = build(:republishing_event, :bulk, bulk_content_type: "all_documents_by_organisation", organisation_id: nil)
        assert_not event.valid?
      end
    end

    context "for any other republishing event" do
      test "must not be present" do
        bulk_event = build(:republishing_event, :bulk, bulk_content_type: "all_documents", organisation_id: "1234")
        assert_not bulk_event.valid?

        non_bulk_event = build(:republishing_event, organisation_id: "1234")
        assert_not non_bulk_event.valid?
      end
    end
  end
end
