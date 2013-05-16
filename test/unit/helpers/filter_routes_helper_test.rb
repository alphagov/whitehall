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

  test "email signup url only accepts certain params" do
    stubs(:params).returns(action: "index", controller: "publications", ignored: "yes")
    refute filter_email_signup_url.match %r{ignored=yes}
  end

  test "email signup url transforms filter params" do
    stubs(:params).returns(action: "index", controller: "publications", topics: ['topic-1'], departments: ['department-1'])
    assert filter_email_signup_url.match %r{topic=topic-1}
    assert filter_email_signup_url.match %r{organisation=department-1}
  end

  test "email signup url ignores 'all' variants of params" do
    stubs(:params).returns(action: "index", controller: "publications", topics: ['all'], departments: ['all'])
    refute filter_email_signup_url.match %r{topic=}
    refute filter_email_signup_url.match %r{organisation=}
  end

  test "email signup url prefixes publication types" do
    stubs(:params).returns(action: "index", controller: "publications", publication_filter_option: "publication-type")
    assert_match %r{document_type=publication_type_publication-type}, filter_email_signup_url
  end

  test "email signup url prefixes announcement types" do
    stubs(:params).returns(action: "index", controller: "announcements", announcement_type_option: "announcement-type")
    assert_match %r{document_type=announcement_type_announcement-type}, filter_email_signup_url
  end

  test "email signup url accepts arguments" do
    stubs(:params).returns(action: "index", controller: "announcements")
    assert_match %r{organisation=cabinet-office}, filter_email_signup_url(organisation: 'cabinet-office')
  end

  test "email signup url accepts policies" do
    assert_match %r{policy=policy-1}, filter_email_signup_url(policy: 'policy-1')
  end

end
