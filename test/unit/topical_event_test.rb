require 'test_helper'

class TopicalEventTest < ActiveSupport::TestCase
  test "archive topical event when it ends" do
    topical_event = create(:topical_event, start_date: 1.year.ago.to_date, end_date: 1.day.ago.to_date)
    assert topical_event.archived?
    assert_equal 0, TopicalEvent.active.count
  end

  test "should include slug in search_index data" do
    topical_event = create(:topical_event, name: "mazzops 2013")
    assert_equal 'mazzops-2013', topical_event.search_index['slug']
  end

  test "should not last more than a year" do
    topical_event = build(:topical_event, start_date: 3.days.ago.to_date, end_date: (Date.today + 1.year))
    refute topical_event.valid?
  end

  test "requires a start_date if end_date is set" do
    topical_event = build(:topical_event, end_date: (Date.today + 1.year))
    refute topical_event.valid?
  end

  test "can be a year long" do
    topical_event = build(:topical_event, start_date: Date.today, end_date: (Date.today + 1.year))
    assert topical_event.valid?
  end

  test "can be a year with a day leeway" do
    topical_event = build(:topical_event, start_date: 1.day.ago.to_date, end_date: (Date.today + 1.year))
    assert topical_event.valid?
  end

  test "should not end before it starts" do
    topical_event = build(:topical_event, start_date: Date.today, end_date: 1.day.ago.to_date)
    refute topical_event.valid?
  end

  test "should be longer than a day" do
    topical_event = build(:topical_event, start_date: Date.today, end_date: Date.today)
    refute topical_event.valid?
  end
end
