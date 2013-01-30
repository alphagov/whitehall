require 'test_helper'

class FilterRoutesHelperTest < ActionView::TestCase
  [:announcements, :publications, :policies].each do |filter|
    test "uses the organisation to generate the route to #{filter} filter" do
      organisation = create(:organisation)
      assert_equal send("#{filter}_path", departments: [organisation.slug]), send("#{filter}_filter_path", organisation)
    end

    test "uses the topic to generate the route to #{filter} filter" do
      topic = create(:topic)
      assert_equal send("#{filter}_path", topics: [topic.slug]), send("#{filter}_filter_path", topic)
    end

    test "uses the world location to generate the route to #{filter} filter" do
      world_location = create(:world_location)
      assert_equal send("#{filter}_path", world_locations: [world_location.slug]), send("#{filter}_filter_path", world_location)
    end

    test "uses the organisation and topic and world_location to generate the route to #{filter} filter" do
      organisation = create(:organisation)
      topic = create(:topic)
      world_location = create(:world_location)
      assert_equal send("#{filter}_path", departments: [organisation.slug], topics: [topic.slug], world_locations: [world_location.slug]), send("#{filter}_filter_path", organisation, topic, world_location)
    end


    test "uses optional hash to route to #{filter} filter" do
      assert_equal send("#{filter}_path", publication_type: 'transparency-data'), send("#{filter}_filter_path", publication_type: 'transparency-data')
    end
  end

end
