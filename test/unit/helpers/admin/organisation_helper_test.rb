require 'test_helper'

class Admin::OrganisationHelperTest < ActionView::TestCase
  test '#topical_event_dates_string handles a topical event with a start date but no end date' do
    topical_event = create(:topical_event, start_date: Date.today)

    assert_equal '11 November 2011', topical_event_dates_string(topical_event)
  end

  test '#topical_event_dates_string handles a topical event with start and end dates' do
    topical_event = create(:topical_event, start_date: Date.today, end_date: Date.today + 1.week)

    assert_equal '11 November 2011 to 18 November 2011', topical_event_dates_string(topical_event)
  end

  test '#topical_event_dates_string handles a topical event with no dates' do
    topical_event = create(:topical_event)

    assert_equal '', topical_event_dates_string(topical_event)
  end
end