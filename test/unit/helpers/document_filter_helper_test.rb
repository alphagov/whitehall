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

  test "#publication_types_for_filter returns all publication filter option types" do
    assert_equal Whitehall::PublicationFilterOption.all, publication_types_for_filter
  end

  test "#announcement_types_for_filter returns all announcement filter option types" do
    announcement_type_options = ["Press releases","News stories","Fatality notices","Speeches","Statements", "Rebuttals"]
    assert_equal announcement_type_options, announcement_types_for_filter.map(&:label)
  end
end
