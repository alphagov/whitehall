require "test_helper"

class Edition::TopicalEventsTest < ActiveSupport::TestCase
  # Legacy - to be deleted when we migrate to config-driven topical events.
  test "#destroy should also remove the topical event membership relationship" do
    topical_event = create(:topical_event)
    edition = create(:published_speech, topical_events: [topical_event])
    relation = edition.topical_event_memberships.first
    edition.destroy!
    assert_not TopicalEventMembership.find_by(id: relation.id)
  end

  # Legacy - to be deleted when we migrate to config-driven topical events.
  test "new edition of document that is a member of a topical event should remain a member of that topical event" do
    topical_event = create(:topical_event)
    edition = create(:published_speech, topical_events: [topical_event])

    new_edition = edition.create_draft(create(:writer))
    new_edition.change_note = "change-note"
    force_publish(new_edition)

    assert_equal topical_event, new_edition.topical_events.first
  end

  # Legacy - to be deleted when we migrate to config-driven topical events.
  test "#destroy should also remove the topical event featuring relationship" do
    topical_event = create(:topical_event)
    edition = create(:published_speech)
    _rel = topical_event.feature(edition_id: edition.id, alt_text: "Woooo", image: create(:topical_event_featuring_image_data))
    relation = edition.topical_event_featurings.first
    edition.destroy!
    assert_not TopicalEventFeaturing.find_by(id: relation.id)
  end

  # Legacy - to be deleted when we migrate to config-driven topical events.
  test "new edition of document featured in topical event should remain featured in that topic event with image, alt text and ordering" do
    featured_image = create(:topical_event_featuring_image_data)
    topical_event = create(:topical_event)
    edition = create(:published_speech)
    topical_event.feature(edition_id: edition.id, image: featured_image, alt_text: "alt-text", ordering: 12)

    new_edition = edition.create_draft(create(:writer))
    new_edition.change_note = "change-note"
    force_publish(new_edition)

    featuring = new_edition.topical_event_featurings.first
    assert featuring.persisted?
    assert_equal featured_image, featuring.image
    assert_equal "alt-text", featuring.alt_text
    assert_equal 12, featuring.ordering
    assert_equal topical_event, featuring.topical_event
  end

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
