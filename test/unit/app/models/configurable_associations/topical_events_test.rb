require "test_helper"

class TopicalEventsTest < ActiveSupport::TestCase
  test "it presents the selected topical event links" do
    topical_events = create_list(:topical_event, 3)
    edition = build(:draft_standard_edition, { topical_events: [topical_events.first, topical_events.last] })

    topical_events_association = ConfigurableAssociations::TopicalEvents.new(edition.topical_events)
    expected_links = { topical_events: [topical_events.first.content_id, topical_events.last.content_id] }
    assert_equal expected_links, topical_events_association.links
  end
end

class TopicalEventsRenderingTest < ActionView::TestCase
  test "it renders topical events form control" do
    topical_events = create_list(:topical_event, 2)
    edition = build(:draft_standard_edition)
    topical_events_association = ConfigurableAssociations::TopicalEvents.new(edition.topical_events)
    render topical_events_association
    assert_dom "label", text: "Topical events"
    topical_events.each do |topical_event|
      assert_dom "option", text: topical_event.name
    end
  end

  test "it renders topical events form control with pre-selected options" do
    topical_events = create_list(:topical_event, 2)
    edition = build(:draft_standard_edition, { topical_events: [topical_events.first] })

    topical_events_association = ConfigurableAssociations::TopicalEvents.new(edition.topical_events)
    render topical_events_association
    assert_dom "option[selected]", text: topical_events.first.name
    assert_not_dom "option[selected]", text: topical_events.last.name
  end
end
