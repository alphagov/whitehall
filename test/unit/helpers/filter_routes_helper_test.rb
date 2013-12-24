# encoding: UTF-8

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

  test "JSON URL generator returns the correct format automatically" do
    stubs(:params).returns(action: "index", controller: "publications")
    assert_equal filter_json_url, "/government/publications.json"
  end

  test "JSON URL generator preserves extra params correctly" do
    stubs(:params).returns(action: "index", controller: "publications", keywords: "test", extra: "extra")
    assert_equal filter_json_url, "/government/publications.json?extra=extra&keywords=test"
  end

  test "JSON URL generator strips spurious query params" do
    stubs(:params).returns(action: "index", controller: "publications", utf8: "✓", _: "jquerycache")
    assert_equal filter_json_url, "/government/publications.json"
  end

end
