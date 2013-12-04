require 'test_helper'

class WorldLocationHelperTest < ActionView::TestCase
  test 'world_location_survey_url returns a URL for spain' do
    location = build(:world_location, slug: 'spain')
    assert world_location_survey_url(location).include? "surveymonkey.com"
  end

  test 'world_location_survey_url returns a URL for spain in spanish' do
    with_locale :es do
      location = build(:world_location, slug: 'spain')
      assert world_location_survey_url(location).include? "surveymonkey.com"
    end
  end
end
