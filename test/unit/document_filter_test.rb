require 'test_helper'

class DocumentFilterTest < ActiveSupport::TestCase
  include DocumentFilterHelpers

  test "#all_topics returns all topics with content, alphabetically" do
    scope = stub('topic scope')
    scope.expects(:order).with(:name)
    Topic.expects(:with_content).returns(scope)

    Whitehall::DocumentFilter.new([]).all_topics
  end

  test "#all_topics_with :announcement returns all topics with announcements, alphabetically" do
    scope = stub('topic scope')
    scope.expects(:order).with(:name)
    Topic.expects(:with_related_announcements).returns(scope)

    Whitehall::DocumentFilter.new([]).all_topics_with(:announcement)
  end

  test "#all_topics_with :publication returns all topics with publications, alphabetically" do
    aardvark = build(:topic, name: "aardvark")
    zebra = build(:topic, name: "zebra")
    topics = [zebra, aardvark]
    Topic.expects(:with_related_publications).returns(topics)

    assert_equal [aardvark, zebra], Whitehall::DocumentFilter.new([]).all_topics_with(:publication)
  end

  test "#all_organisations returns all organisations with content, alphabetically" do
    final_scope = stub('final scope')
    final_scope.expects(:ordered_by_name_ignoring_prefix)
    scope = stub('organisation scope')
    scope.expects(:group).with(:name).returns(final_scope)
    Organisation.expects(:joins).with(:published_document_types).returns(scope)

    Whitehall::DocumentFilter.new([]).all_organisations_with(:document_type)
  end

  test "#publication_types_for_filter returns all publication filter option types" do
    assert_equal Whitehall::PublicationFilterOption.all, Whitehall::DocumentFilter.new([]).publication_types_for_filter
  end

  test "#announcement_types_for_filter returns all announcement filter option types" do
    announcement_type_options = ["Press releases","News stories","Fatality notices","Speeches","Statements", "Rebuttals"]
    assert_equal announcement_type_options, Whitehall::DocumentFilter.new([]).announcement_types_for_filter.map(&:label)
  end

  test "#selected_topics returns an empty set by default" do
    assert_equal [], Whitehall::DocumentFilter.new(document_scope).selected_topics
  end

  test "#selected_organisations returns an empty set by default" do
    assert_equal [], Whitehall::DocumentFilter.new(document_scope).selected_organisations
  end

  test "#selected_publication_filter_option returns nil by default" do
    assert_nil Whitehall::DocumentFilter.new(document_scope).selected_publication_filter_option
  end

  test "#documents returns the given set of documents when unfiltered" do
    assert_equal document_scope, Whitehall::DocumentFilter.new(document_scope).documents
  end

  test "alphabetical direction returns the given set of documents ordered alphabetically" do
    document_scope.expects(:alphabetical)
    Whitehall::DocumentFilter.new(document_scope, direction: "alphabetical").documents
  end

  test "topics param filters the documents by topic using slugs" do
    topic = stub_topic("car-tax")

    filtered_scope = stub_document_scope('filtered_scope')
    document_scope.expects(:published_in_topic).with([topic]).returns(filtered_scope)

    filter = Whitehall::DocumentFilter.new(document_scope, topics: [topic.slug])

    assert_equal filtered_scope, filter.documents
  end

  test "topics param sets #selected_topics" do
    topic = stub_topic("car-tax")

    filtered_scope = stub_document_scope('filtered_scope')
    document_scope.stubs(:published_in_topic).with([topic]).returns(filtered_scope)

    filter = Whitehall::DocumentFilter.new(document_scope, topics: [topic.slug])

    assert_equal [topic], filter.selected_topics
  end

  test "topics param does not filter if topics are not present" do
    document_scope.expects(:published_in_topic).never

    filter = Whitehall::DocumentFilter.new(document_scope, topics: "")

    assert_equal document_scope, filter.documents
  end

  test "topics param does not filter if topic is 'all'" do
    document_scope.expects(:published_in_topic).never

    filter = Whitehall::DocumentFilter.new(document_scope, topics: ['all'])

    assert_equal document_scope, filter.documents
  end

  test "departments param filters the documents by organisation using slugs" do
    organisation = stub_organisation('defra')

    filtered_scope = stub_document_scope('filtered_scope')
    document_scope.stubs(:in_organisation).with([organisation]).returns(filtered_scope)

    filter = Whitehall::DocumentFilter.new(document_scope, departments: [organisation.slug])

    assert_equal filtered_scope, filter.documents
  end

  test "departments param sets #selected_organisations" do
    organisation = stub_organisation('defra')

    filter = Whitehall::DocumentFilter.new(document_scope, departments: [organisation.slug])

    assert_equal [organisation], filter.selected_organisations
  end

  test "does not filter if departments are not present" do
    document_scope.expects(:in_organisation).never
    Whitehall::DocumentFilter.new(document_scope, departments: "")
  end

  test "does not filter if departments is 'all'" do
    document_scope.expects(:in_organisation).never
    Whitehall::DocumentFilter.new(document_scope, departments: ['all'])
  end

  test "keywords param filters by content containing each keyword" do
    filtered_scope = stub_document_scope('filtered scope')
    document_scope.expects(:with_summary_containing).with("alpha", "beta").returns(filtered_scope)

    filter = Whitehall::DocumentFilter.new(document_scope, keywords: "alpha beta")

    assert_equal filtered_scope, filter.documents
  end

  test "keywords param sets the keywords attribute" do
    filter = Whitehall::DocumentFilter.new(document_scope, keywords: "alpha beta")
    assert_equal %w(alpha beta), filter.keywords
  end

  test "keywords param does not filter if no keywords were given" do
    document_scope.expects(:with_summary_containing).never
    Whitehall::DocumentFilter.new(document_scope, keywords: '')
  end

  test "strips leading and trailing spaces from keywords" do
    filtered_scope = stub_document_scope('filtered scope')
    document_scope.expects(:with_summary_containing).with("alpha", "beta").returns(filtered_scope)

    filter = Whitehall::DocumentFilter.new(document_scope, keywords: " alpha   beta ")

    assert_equal filtered_scope, filter.documents
  end

  test "date and direction param allows filtering before a date" do
    document_scope.expects(:published_before).with(Date.parse("2012-01-01 12:23:45")).returns(document_scope)
    Whitehall::DocumentFilter.new(document_scope, date: "2012-01-01 12:23:45", direction: "before").documents
  end

  test "direction before a date returns documents in reverse chronological order" do
    document_scope.expects(:in_reverse_chronological_order).returns(document_scope)
    Whitehall::DocumentFilter.new(document_scope, date: "2012-01-01 12:23:45", direction: "before").documents
  end

  test "direction param sets direction attribute" do
    assert_equal "before", Whitehall::DocumentFilter.new(document_scope, direction: "before").direction
  end

  test "date param sets date attribute" do
    assert_equal Date.parse("2012-01-01 12:23:45"), Whitehall::DocumentFilter.new(document_scope, date: "2012-01-01 12:23:45").date
  end

  test "invalid date param sets date attribute to nil" do
    assert_equal nil, Whitehall::DocumentFilter.new(document_scope, date: "invalid-date").date
  end

  test "can filter after a date" do
    document_scope.expects(:published_after).with(Date.parse("2012-01-01 12:23:45")).returns(document_scope)
    Whitehall::DocumentFilter.new(document_scope, date: "2012-01-01 12:23:45", direction: "after").documents
  end

  test "filtering after a date returns documents in chronological order" do
    document_scope.expects(:in_chronological_order).returns(document_scope)
    Whitehall::DocumentFilter.new(document_scope, date: "2012-01-01 12:23:45", direction: "after").documents
  end

  test "publication_type param filters by publication type" do
    publication_filter_option = stub_publication_filter_option("testing filter - statistics", publication_types: [stub('type', id: 123)])

    filtered_scope = stub_document_scope('filtered_scope')
    document_scope.expects(:where).with(publication_type_id: [123]).returns(filtered_scope)

    filter = Whitehall::DocumentFilter.new(document_scope, publication_filter_option: publication_filter_option.slug)
    assert_equal filtered_scope, filter.documents
  end

  test "publication_type param can also filter by publication edition type" do
    publication_filter_option = stub_publication_filter_option("testing filter - statistics", publication_types: [stub('type', id: 123), stub('other type', id: 234)], edition_types: ["EditionType"])

    filtered_scope = stub_document_scope('filtered_scope')
    expected_query = "(`editions`.`publication_type_id` IN (123, 234) OR `editions`.`type` IN ('EditionType'))"
    document_scope.expects(:where).with(responds_with(:to_sql, expected_query)).returns(filtered_scope)

    filter = Whitehall::DocumentFilter.new(document_scope, publication_filter_option: publication_filter_option.slug)
    assert_equal filtered_scope, filter.documents
  end

  test "publication_filter_option param sets #selected_publication_filter_option" do
    publication_filter_option = stub_publication_filter_option("testing filter option - statistics")

    filter = Whitehall::DocumentFilter.new(document_scope, publication_filter_option: publication_filter_option.slug)

    assert_equal publication_filter_option, filter.selected_publication_filter_option
  end

  test "publication_type param also sets #selected_publication_filter_option to keep old links working" do
    publication_filter_option = stub_publication_filter_option("testing filter option - statistics")
    filter = Whitehall::DocumentFilter.new(document_scope, publication_type: publication_filter_option.slug)

    assert_equal publication_filter_option, filter.selected_publication_filter_option
  end

  test "can filter announcements by type" do
    news_article = create(:published_news_article, news_article_type: NewsArticleType::NewsStory)
    fatality_notice = create(:published_fatality_notice)
    transcript = create(:published_speech, speech_type: SpeechType::Transcript)
    statement = create(:published_speech, speech_type: SpeechType::WrittenStatement)

    assert_equal [news_article.id], Whitehall::DocumentFilter.new(Announcement.published, announcement_type_option: "news-stories").documents.map(&:id)
    assert_equal [fatality_notice.id], Whitehall::DocumentFilter.new(Announcement.published, announcement_type_option: "fatality-notices").documents.map(&:id)
    assert_equal [transcript.id], Whitehall::DocumentFilter.new(Announcement.published, announcement_type_option: "speeches").documents.map(&:id)
    assert_equal [statement.id], Whitehall::DocumentFilter.new(Announcement.published, announcement_type_option: "statements").documents.map(&:id)
  end

  test "publication_filter_option overwrites older publication_type param" do
    publication_filter_option = stub_publication_filter_option("testing filter option - statistics")
    filter = Whitehall::DocumentFilter.new(document_scope, publication_type: 'foobar', publication_filter_option: publication_filter_option.slug)

    assert_equal publication_filter_option, filter.selected_publication_filter_option
  end

  test "if page param given, returns a page of documents using page size of 20" do
    document_scope.expects(:page).with(3).returns(document_scope)
    document_scope.expects(:per).with(20).returns(document_scope)
    with_number_of_documents_per_page(20) do
      Whitehall::DocumentFilter.new(document_scope, page: 3).documents
    end
  end

  test "allows combination of filter options" do
    organisation = stub_organisation('defra')
    topic = stub_topic("car-tax")

    document_scope.expects(:in_organisation).with([organisation]).returns(document_scope)
    document_scope.expects(:published_in_topic).with([topic]).returns(document_scope)
    document_scope.expects(:page).with(2).returns(document_scope)

    filter = Whitehall::DocumentFilter.new(document_scope,
      departments: [organisation.slug],
      topics: [topic.slug],
      page: 2)
    filter.documents

    assert_equal [organisation], filter.selected_organisations
    assert_equal [topic], filter.selected_topics
  end

  test "avoids loading the wrong document when combining topic and department filter" do
    organisation = create(:organisation)
    policy = create(:published_policy)
    topic = create(:topic, policies: [policy])
    news_article = create(:published_news_article, related_policies: [policy], organisations: [organisation])

    document_scope = Announcement.published.includes(:document, :organisations)
    filter = Whitehall::DocumentFilter.new(document_scope,
      departments: [organisation.slug],
      topics: [topic.slug],
      page: 1)
    results = filter.documents

    assert_equal news_article.document_id, filter.documents.first.document.id
  end

  test 'does not use n+1 selects when filtering by topics' do
    policy = create(:published_policy)
    topic = create(:topic, policies: [policy])
    3.times { create(:published_publication, related_policies: [policy]) }
    assert 3 > count_queries { Whitehall::DocumentFilter.new(Publication.published, topics: [topic.slug]).documents }
  end

  test 'does not use n+1 selects when filtering by organisations' do
    organisation = create(:organisation)
    3.times { create(:published_publication, organisations: [organisation]) }
    assert 3 > count_queries { Whitehall::DocumentFilter.new(Publication.published, departments: [organisation.slug]).documents }
  end

  test 'does not use n+1 selects when filtering by keywords' do
    3.times { |i| create(:published_publication, title: "keyword-#{i}") }
    assert 3 > count_queries { Whitehall::DocumentFilter.new(Publication.published, keywords: "keyword").documents }
  end

  test 'does not use n+1 selects when filtering by date' do
    3.times { |i| create(:published_publication, publication_date: i.months.ago) }
    assert 3 > count_queries { Whitehall::DocumentFilter.new(Publication.published, date: "2012-01-01 12:23:45", direction: "before").documents }
  end

  test "can filter announcements by topic" do
    policy = create(:published_policy)
    topic = create(:topic, policies: [policy])
    create(:published_speech, related_policies: [policy])
    create(:published_news_article, related_policies: [policy])
    create(:published_speech)
    create(:published_news_article)
    unfiltered_announcements = Announcement.published
    assert_equal 2, Whitehall::DocumentFilter.new(unfiltered_announcements, topics: [topic.slug]).documents.count
  end

  def self.test_delegates_to_documents(method)
    test "delegates ##{method} to documents" do
      document_scope.expects(method)
      Whitehall::DocumentFilter.new(document_scope).send(method)
    end
  end

  test_delegates_to_documents(:count)
  test_delegates_to_documents(:num_pages)
  test_delegates_to_documents(:current_page)
  test_delegates_to_documents(:last_page?)
  test_delegates_to_documents(:first_page?)

private

  def document_scope
    @document_scope ||= stub_document_scope('unfiltered document scope')
  end

  def stub_document_scope(name)
    document_scope = stub(name,
      count: stub_everything,
      current_page: stub_everything,
      num_pages: stub_everything
    )
    document_scope.stubs(:arel_table).returns(Edition.arel_table)
    document_scope.stubs(:in_reverse_chronological_order).returns(document_scope)
    document_scope.stubs(:in_chronological_order).returns(document_scope)
    document_scope.stubs(:with_summary_containing).returns(document_scope)
    document_scope.stubs(:published_before).returns(document_scope)
    document_scope.stubs(:published_after).returns(document_scope)
    document_scope.stubs(:alphabetical).returns(document_scope)
    document_scope.stubs(:published_in_topic).returns(document_scope)
    document_scope.stubs(:in_organisation).returns(document_scope)
    document_scope.stubs(:where).with(has_entry(:publication_type_id, anything)).returns(document_scope)
    document_scope.stubs(:per).returns(document_scope)
    document_scope.stubs(:page).returns(document_scope)
    document_scope
  end

  def stub_topic(slug)
    topic = stub("topic-#{slug}", slug: slug, name: slug.humanize)
    Topic.stubs(:where).with(slug: [slug]).returns([topic])
    topic
  end

  def stub_organisation(slug)
    organisation = stub("organisation-#{slug}", slug: slug, name: slug.humanize)
    Organisation.stubs(:where).with(slug: [slug]).returns([organisation])
    organisation
  end

  def stub_publication_type(slug, attributes={})
    publication_type = stub("publication-type-#{slug}", {id: slug, slug: slug, pluralized_name: slug.humanize.pluralize}.merge(attributes))
    PublicationType.stubs(:find_by_slug).with(slug).returns(publication_type)
    publication_type
  end

  def stub_publication_filter_option(label, attributes={})
    publication_filter_option = stub("publication-filter-option-#{label}", {
      label: label.humanize.pluralize,
      slug: label,
      publication_types: [stub_publication_type(label)],
      edition_types: []
    }.merge(attributes))
    Whitehall::PublicationFilterOption.expects(:find_by_slug).with(label).at_least_once.returns(publication_filter_option)
    publication_filter_option
  end
end
