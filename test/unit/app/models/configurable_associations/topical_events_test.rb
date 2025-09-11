require "test_helper"

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
