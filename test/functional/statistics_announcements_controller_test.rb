require 'test_helper'

class StatisticsAnnouncementsControllerTest < ActionController::TestCase
  test "#index assign a StatisticsAnnouncementsFilter, populated with get params" do
    organisation = create :organisation
    topic = create :topic

    get :index, keywords: "wombats",
                from_date: "2050-02-02",
                to_date: "2055-01-01",
                organisations: [organisation.slug],
                topics: [topic.slug]

    assert assigns(:filter).is_a? Frontend::StatisticsAnnouncementsFilter
    assert_equal "wombats", assigns(:filter).keywords
    assert_equal Date.new(2050, 2, 2), assigns(:filter).from_date
    assert_equal Date.new(2055, 1, 1), assigns(:filter).to_date
    assert_equal [organisation], assigns(:filter).organisations
    assert_equal [topic], assigns(:filter).topics
  end
end
