require "test_helper"

class Edition::TopicalEventsTest < ActiveSupport::TestCase
  test "new edition of document that is associated with a topical event document should retain that association" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("topical_event"))
    topical_event = create(:standard_edition, configurable_document_type: "topical_event")
    edition = create(:published_speech, topical_event_documents: [topical_event.document])

    new_edition = edition.create_draft(create(:writer))
    new_edition.change_note = "change-note"
    force_publish(new_edition)

    assert_equal topical_event.document, new_edition.topical_event_documents.first
  end

  test "can_be_associated_with_topical_events? returns true for legacy content types that include the module" do
    self.class.const_set("DummyLegacyEdition", Class.new(Edition) do
      include Edition::TopicalEvents
    end)

    edition = DummyLegacyEdition.new
    assert edition.can_be_associated_with_topical_events?
  end

  test "can_be_associated_with_topical_events? can be overridden by the class that includes it (e.g. to make its return value config-driven)" do
    self.class.const_set("DummyStandardEdition", Class.new(Edition) do
      include Edition::TopicalEvents

      def can_be_associated_with_topical_events?
        false
      end
    end)

    edition = DummyStandardEdition.new
    assert_not edition.can_be_associated_with_topical_events?
  end
end
