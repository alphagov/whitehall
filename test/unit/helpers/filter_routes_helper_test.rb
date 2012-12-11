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

    test "uses the organisation and topic to generate the route to #{filter} filter" do
      organisation = create(:organisation)
      topic = create(:topic)
      assert_equal send("#{filter}_path", departments: [organisation.slug], topics: [topic.slug]), send("#{filter}_filter_path", organisation, topic)
    end

    test "uses optional hash to route to #{filter} filter" do
      assert_equal send("#{filter}_path", publication_type: 'transparency-data'), send("#{filter}_filter_path", publication_type: 'transparency-data')
    end
  end

end
