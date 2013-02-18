require 'test_helper'

class DocumentFilterHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "#all_topics_with :announcement returns all topics with announcements, alphabetically" do
    scope = stub('topic scope')
    scope.expects(:order).with(:name)
    Topic.expects(:with_related_announcements).returns(scope)

    all_topics_with(:announcement)
  end

  test "#all_topics_with :publication returns all topics with publications, alphabetically" do
    aardvark = build(:topic, name: "aardvark")
    zebra = build(:topic, name: "zebra")
    topics = [zebra, aardvark]
    Topic.expects(:with_related_publications).returns(topics)

    assert_equal [aardvark, zebra], all_topics_with(:publication)
  end

  test "#all_organisations_with returns all organisations with content, alphabetically" do
    final_scope = stub('final scope')
    final_scope.expects(:ordered_by_name_ignoring_prefix)
    scope = stub('organisation scope')
    scope.expects(:group).with(:name).returns(final_scope)
    Organisation.expects(:joins).with(:published_document_types).returns(scope)

    all_organisations_with(:document_type)
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
    announcement_type_options = ["Press releases","News stories","Fatality notices","Speeches","Statements", "Rebuttals"]
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
