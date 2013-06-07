require 'test_helper'

class DocumentFilterHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "#all_organisations_with returns all organisations that have published editions" do
    Organisation.expects(:with_published_editions).with(:announcement)
    all_organisations_with(:announcement)
  end

  test "#all_locations_with :publication returns all world locations with publications, alphabetically" do
    final_scope = stub('final scope')
    final_scope.expects(:ordered_by_name)
    WorldLocation.expects(:with_publications).returns(final_scope)

    all_locations_with(:publication)
  end

  test "#all_locations_with :announcement returns all world locations with announcements, alphabetically" do
    final_scope = stub('final scope')
    final_scope.expects(:ordered_by_name)
    WorldLocation.expects(:with_announcements).returns(final_scope)

    all_locations_with(:announcement)
  end

  test "#publication_types_for_filter returns all publication filter option types" do
    assert_equal Whitehall::PublicationFilterOption.all, publication_types_for_filter
  end

  test "#announcement_types_for_filter returns all announcement filter option types" do
    announcement_type_options = ["Press releases", "News stories", "Fatality notices", "Speeches", "Statements", "Government responses"]
    assert_equal announcement_type_options, announcement_types_for_filter.map(&:label)
  end

  test "remove_filter_from_params removes filter from params" do
    stubs(:params).returns({ first: 'one', second: ['two', 'three'] })

    assert_equal ({ first: nil, second: ['two', 'three'] }), remove_filter_from_params(:first)
    assert_equal ({ first: 'one', second: ['three'] }), remove_filter_from_params(:second, 'two')
  end

  test "filter_results_selections gets objects ready for mustache" do
    topic = build(:topic, slug: 'my-slug')
    stubs(:params).returns({ controller: 'announcements', action: 'index', "topics" => ['my-slug', 'three'] })

    assert_equal [{ name: topic.name, value: topic.slug, url: announcements_path(topics: ['three']), joining: '' }], filter_results_selections([topic], 'topics')
  end

  test "filter_results_selections handles when params aren't in the expected format" do
    topic = build(:topic, slug: 'my-slug')
    stubs(:params).returns({ controller: 'announcements', action: 'index', "topics" => 'my-slug' })

    assert_equal [{ name: topic.name, value: topic.slug, url: announcements_path, joining: '' }], filter_results_selections([topic], 'topics')
  end

  test "filter_results_keywords gets objects ready for mustache" do
    keywords = %w{one two}
    stubs(:params).returns({ controller: 'announcements', action: 'index', "keywords" => 'one two' })

    assert_equal [
      { name: 'one', url: announcements_path({ keywords: 'two' }), joining: 'or'},
      { name: 'two', url: announcements_path({ keywords: 'one' }), joining: ''},
    ], filter_results_keywords(keywords)
  end
end
