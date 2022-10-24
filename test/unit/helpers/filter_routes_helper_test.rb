require "test_helper"

class FilterRoutesHelperTest < ActionView::TestCase
  test "given an organisation should return the correct publication URL" do
    organisation = create(:organisation, slug: "department-for-administrative-affairs")

    assert_equal "/search/all?order=updated-newest&organisation=department-for-administrative-affairs",
                 publications_filter_path(organisation)
  end

  test "given a topical event should return the correct publication URL" do
    topical_event = create(:topical_event, slug: "important-event")

    assert_equal "/search/all?order=updated-newest&topical_events%5B%5D=important-event",
                 publications_filter_path(topical_event)
  end

  test "given a world location should return the correct publication URL" do
    world_location = create(:world_location, slug: "some-location")

    assert_equal "/search/all?order=updated-newest&world_locations%5B%5D=some-location",
                 publications_filter_path(world_location)
  end
end
