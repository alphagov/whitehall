require 'test_helper'

class DocumentFilterTest < ActiveSupport::TestCase

  test "#all_topics returns all topics with content, alphabetically" do
    scope = stub('topic scope')
    scope.expects(:order).with(:name)
    Topic.expects(:with_content).returns(scope)

    Whitehall::DocumentFilter.new([]).all_topics
  end

  test "#all_organisations returns all organisations with content, alphabetically" do
    final_scope = stub('final scope')
    final_scope.expects(:ordered_by_name_ignoring_prefix)
    scope = stub('organisation scope')
    scope.expects(:group).with(:name).returns(final_scope)
    Organisation.expects(:joins).with(:published_publications).returns(scope)

    Whitehall::DocumentFilter.new([]).all_organisations
  end

  test "#selected_topics returns an empty set by default" do
    assert_equal [], Whitehall::DocumentFilter.new(document_scope).selected_topics
  end

  test "#selected_organisations returns an empty set by default" do
    assert_equal [], Whitehall::DocumentFilter.new(document_scope).selected_organisations
  end

  test "#documents returns the given set of documents when unfiltered" do
    assert_equal document_scope, Whitehall::DocumentFilter.new(document_scope).documents
  end

  test "#documents returns documents reverse chronological order by default" do
    document_scope.expects(:in_reverse_chronological_order).returns(document_scope)
    Whitehall::DocumentFilter.new(document_scope).documents
  end

  test "#by_topics filters the documents by topic using slugs" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    topic = stub('topic')
    Topic.expects(:where).with({slug: ['topic-slug']}).returns([topic])

    filtered_scope = stub_document_scope('filtered_scope')
    document_scope.expects(:in_topic).with([topic]).returns(filtered_scope)

    filter.by_topics(['topic-slug'])

    assert_equal filtered_scope, filter.documents
  end

  test "#by_topics sets #selected_topics" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    topic = stub('topic')
    Topic.stubs(:where).returns([topic])

    filtered_scope = stub_document_scope('filtered_scope')
    document_scope.stubs(:in_topic).with([topic]).returns(filtered_scope)

    filter.by_topics(['topic-slug'])

    assert_equal [topic], filter.selected_topics
  end

  test "#by_topics does not filter if topics are not present" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.expects(:in_topic).never

    filter.by_topics(nil)

    assert_equal document_scope, filter.documents
  end

  test "#by_topics does not filter if topic is 'all'" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.expects(:in_topic).never

    filter.by_topics(['all'])

    assert_equal document_scope, filter.documents
  end

  test "#by_organisations filters the documents by organisation using slugs" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    organisation = stub('organisation')
    Organisation.expects(:where).with({slug: ['organisation-slug']}).returns([organisation])

    filtered_scope = stub_document_scope('filtered_scope')
    document_scope.expects(:in_organisation).with([organisation]).returns(filtered_scope)

    filter.by_organisations(['organisation-slug'])

    assert_equal filtered_scope, filter.documents
  end

  test "#by_organisations sets #selected_organisations" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    organisation = stub('organisation')
    Organisation.stubs(:where).returns([organisation])

    filter.by_organisations(['organisation-slug'])

    assert_equal [organisation], filter.selected_organisations
  end

  test "#by_organisations does not filter if organisations are not present" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.expects(:in_topic).never

    filter.by_organisations(nil)

    assert_equal document_scope, filter.documents
  end

  test "#by_organisations does not filter if organisations is 'all'" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.expects(:in_topic).never

    filter.by_organisations(['all'])

    assert_equal document_scope, filter.documents
  end

  test "#by_keywords filters by content containing each keyword" do
    filter = Whitehall::DocumentFilter.new(document_scope)
    filtered_scope = stub_document_scope('filtered scope')
    document_scope.expects(:with_content_containing).with("alpha", "beta").returns(filtered_scope)

    filter.by_keywords("alpha beta")

    assert_equal filtered_scope, filter.documents
  end

  test "#by_keywords sets the keywords" do
    filter = Whitehall::DocumentFilter.new(document_scope)
    document_scope.stubs(:with_content_containing)

    filter.by_keywords("alpha beta")

    assert_equal %w(alpha beta), filter.keywords
  end

  test "#by_keywords does not filter if no keywords were given" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.expects(:with_content_containing).never

    filter.by_keywords('')
  end

  test "#by_date can filter before a date" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.expects(:published_before).with(Date.parse("2012-01-01 12:23:45")).returns(document_scope)

    filter.by_date("2012-01-01 12:23:45", "before")
  end

  test "#by_date before a date returns documents in reverse chronological order" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.stubs(:published_before).returns(document_scope)
    document_scope.expects(:in_reverse_chronological_order).returns(document_scope)

    filter.by_date("2012-01-01 12:23:45", "before").documents
  end

  test "#by_date can filter after a date" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.expects(:published_after).with(Date.parse("2012-01-01 12:23:45")).returns(document_scope)

    filter.by_date("2012-01-01 12:23:45", "after")
  end

  test "#by_date after a date returns documents in chronological order" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.stubs(:published_after).returns(document_scope)
    document_scope.expects(:in_chronological_order).returns(document_scope)

    filter.by_date("2012-01-01 12:23:45", "after").documents
  end

  test "paginate returns a page of documents" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    final_page_scope = stub_document_scope('final page scope')
    paginated_scope = stub_document_scope('paginated scope')
    paginated_scope.stubs(:per).returns(final_page_scope)
    document_scope.stubs(:page).with(3).returns(paginated_scope)

    filter.paginate(3)

    assert_equal final_page_scope, filter.documents
  end

  test "paginate selects the given page" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    document_scope.expects(:page).with(1).returns(stub_everything)

    filter.paginate(1)
    filter.documents
  end

  test "paginate uses a page size of 20" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    paginated_scope = stub_document_scope('paginated scope')
    document_scope.stubs(:page).returns(paginated_scope)
    paginated_scope.expects(:per).with(20)

    filter.paginate(3)
    filter.documents
  end

  test "allows chaining of filter options" do
    filter = Whitehall::DocumentFilter.new(document_scope)

    organisation = stub('organisation')
    Organisation.stubs(:where).returns([organisation])
    topic = stub('topic')
    Topic.stubs(:where).returns([topic])

    document_scope.expects(:in_organisation).with([organisation]).returns(document_scope)
    document_scope.expects(:in_topic).with([topic]).returns(document_scope)
    document_scope.expects(:page).with(2).returns(document_scope)

    filter.by_organisations(['organisation-slug']).by_topics(['topic-slug']).paginate(2).documents

    assert_equal [organisation], filter.selected_organisations
    assert_equal [topic], filter.selected_topics
  end

  test 'does not use n+1 selects when filtering by topics' do
    policy = create(:published_policy)
    topic = create(:topic, policies: [policy])
    3.times { create(:published_publication, related_policies: [policy]) }
    assert 3 > count_queries { Whitehall::DocumentFilter.new(Publication.published).by_topics([topic.slug]).documents }
  end

  test 'does not use n+1 selects when filtering by organisations' do
    organisation = create(:organisation)
    3.times { create(:published_publication, organisations: [organisation]) }
    assert 3 > count_queries { Whitehall::DocumentFilter.new(Publication.published).by_organisations([organisation.slug]).documents }
  end

  test 'does not use n+1 selects when filtering by keywords' do
    3.times { |i| create(:published_publication, title: "keyword-#{i}") }
    assert 3 > count_queries { Whitehall::DocumentFilter.new(Publication.published).by_keywords("keyword").documents }
  end

  test 'does not use n+1 selects when filtering by date' do
    3.times { |i| create(:published_publication, publication_date: i.months.ago) }
    assert 3 > count_queries { Whitehall::DocumentFilter.new(Publication.published).by_date("2012-01-01 12:23:45", "before").documents }
  end

  private

  def document_scope
    return @document_scope if @document_scope
    @document_scope = stub_document_scope('document scope')
    @document_scope
  end

  def stub_document_scope(name)
    stub = stub(name)
    stub.stubs(:in_reverse_chronological_order).returns(stub)
    stub.stubs(:in_topic).returns(stub)
    stub.stubs(:in_organisation).returns(stub)
    stub.stubs(:page).returns(stub)
    stub.stubs(:per).returns(stub)
    stub
  end
end