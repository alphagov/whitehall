require "test_helper"

class TopicalEventDocumentsRenderingTest < ActionView::TestCase
  setup do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:configurable_document_types, true)
  end

  teardown do
    @test_strategy.switch!(:configurable_document_types, false)
  end

  test "it does not render the topical events form control if configurable documents are disabled" do
    @test_strategy.switch!(:configurable_document_types, false)

    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type").merge(build_configurable_document_type("topical_event")))
    topical_events = create_list(:published_standard_edition, 3, configurable_document_type: "topical_event")
    edition = build(:draft_standard_edition, {
      topical_event_documents: [topical_events.first.document, topical_events.last.document],
    })

    topical_events_association = ConfigurableAssociations::TopicalEventDocuments.new(edition.topical_event_documents)
    render topical_events_association

    assert_dom "label", text: "Topical events (experimental)", count: 0

    @test_strategy.switch!(:configurable_document_types, true)
  end

  test "it renders topical events form control" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type").merge(build_configurable_document_type("topical_event")))
    topical_events = create_list(:published_standard_edition, 3, configurable_document_type: "topical_event")
    edition = build(:draft_standard_edition, {
      topical_event_documents: [topical_events.first.document, topical_events.last.document],
    })

    topical_events_association = ConfigurableAssociations::TopicalEventDocuments.new(edition.topical_event_documents)
    render topical_events_association
    assert_dom "label", text: "Topical events (experimental)"
    topical_events.each do |topical_event|
      assert_dom "option", text: topical_event.title
    end
  end

  test "it renders topical events form control with pre-selected options" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type").merge(build_configurable_document_type("topical_event")))
    topical_events = create_list(:published_standard_edition, 3, configurable_document_type: "topical_event")
    edition = build(:draft_standard_edition, {
      topical_event_documents: [topical_events.first.document],
    })

    topical_events_association = ConfigurableAssociations::TopicalEventDocuments.new(edition.topical_event_documents)
    render topical_events_association
    assert_dom "option[selected]", text: topical_events.first.title
    assert_not_dom "option[selected]", text: topical_events.last.title
  end

  test "it includes draft topical events in the list of options" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type").merge(build_configurable_document_type("topical_event")))
    edition = create(:draft_standard_edition, title: "Draft topical event", configurable_document_type: "topical_event")

    topical_events_association = ConfigurableAssociations::TopicalEventDocuments.new(edition.topical_event_documents)
    render topical_events_association
    assert_dom "option", text: "Draft topical event"
  end
end
