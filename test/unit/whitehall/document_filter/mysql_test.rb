require 'test_helper'

module Whitehall::DocumentFilter
  class MysqlTest < ActiveSupport::TestCase
    include DocumentFilterHelpers

    test "#selected_topics returns an empty set by default" do
      assert_equal [], Whitehall::DocumentFilter::Mysql.new.selected_topics
    end

    test "#selected_organisations returns an empty set by default" do
      assert_equal [], Whitehall::DocumentFilter::Mysql.new.selected_organisations
    end

    test "#selected_publication_filter_option returns nil by default" do
      assert_nil Whitehall::DocumentFilter::Mysql.new.selected_publication_filter_option
    end

    test "alphabetical direction returns the given set of documents ordered alphabetically" do
      document_scope.expects(:alphabetical)
      filter = Whitehall::DocumentFilter::Mysql.new(direction: "alphabetical")
      filter.documents = document_scope
      filter.apply_filters
    end

    test "topics param filters the documents by topic using slugs" do
      topic = stub_topic("car-tax")

      filtered_scope = stub_document_scope('filtered_scope')
      document_scope.expects(:published_in_topic).with([topic]).returns(filtered_scope)

      filter = Whitehall::DocumentFilter::Mysql.new(topics: [topic.slug])
      filter.documents = document_scope
      filter.apply_filters

      assert_equal filtered_scope, filter.documents
    end

    test "topics param sets #selected_topics" do
      topic = stub_topic("car-tax")

      filtered_scope = stub_document_scope('filtered_scope')
      document_scope.stubs(:published_in_topic).with([topic]).returns(filtered_scope)

      filter = Whitehall::DocumentFilter::Mysql.new(topics: [topic.slug])
      filter.documents = document_scope
      filter.apply_filters

      assert_equal [topic], filter.selected_topics
    end

    test "topics param does not filter if topics are not present" do
      document_scope.expects(:published_in_topic).never

      filter = Whitehall::DocumentFilter::Mysql.new( topics: "")
      filter.documents = document_scope
      filter.apply_filters

      assert_equal document_scope, filter.documents
    end

    test "topics param does not filter if topic is 'all'" do
      document_scope.expects(:published_in_topic).never

      filter = Whitehall::DocumentFilter::Mysql.new( topics: ['all'])
      filter.documents = document_scope
      filter.apply_filters

      assert_equal document_scope, filter.documents
    end

    test "departments param filters the documents by organisation using slugs" do
      organisation = stub_organisation('defra')

      filtered_scope = stub_document_scope('filtered_scope')
      document_scope.stubs(:in_organisation).with([organisation]).returns(filtered_scope)

      filter = Whitehall::DocumentFilter::Mysql.new( departments: [organisation.slug])
      filter.documents = document_scope
      filter.apply_filters

      assert_equal filtered_scope, filter.documents
    end

    test "departments param sets #selected_organisations" do
      organisation = stub_organisation('defra')

      filter = Whitehall::DocumentFilter::Mysql.new( departments: [organisation.slug])
      filter.documents = document_scope
      filter.apply_filters

      assert_equal [organisation], filter.selected_organisations
    end

    test "does not filter if departments are not present" do
      document_scope.expects(:in_organisation).never
      filter = Whitehall::DocumentFilter::Mysql.new(departments: "")
      filter.documents = document_scope
      filter.apply_filters
    end

    test "does not filter if departments is 'all'" do
      document_scope.expects(:in_organisation).never
      filter = Whitehall::DocumentFilter::Mysql.new( departments: ['all'])
      filter.documents = document_scope
      filter.apply_filters
    end

    test "keywords param filters by content containing each keyword" do
      filtered_scope = stub_document_scope('filtered scope')
      document_scope.expects(:with_title_or_summary_containing).with("alpha", "beta").returns(filtered_scope)

      filter = Whitehall::DocumentFilter::Mysql.new( keywords: "alpha beta")
      filter.documents = document_scope
      filter.apply_filters

      assert_equal filtered_scope, filter.documents
    end

    test "keywords param sets the keywords attribute" do
      filter = Whitehall::DocumentFilter::Mysql.new(keywords: "alpha beta")
      assert_equal %w(alpha beta), filter.keywords
    end

    test "keywords param does not filter if no keywords were given" do
      document_scope.expects(:with_title_or_summary_containing).never
      filter = Whitehall::DocumentFilter::Mysql.new(document_scope, keywords: '')
      filter.documents = document_scope
      filter.apply_filters
    end

    test "strips leading and trailing spaces from keywords" do
      filtered_scope = stub_document_scope('filtered scope')
      document_scope.expects(:with_title_or_summary_containing).with("alpha", "beta").returns(filtered_scope)

      filter = Whitehall::DocumentFilter::Mysql.new( keywords: " alpha   beta ")
      filter.documents = document_scope
      filter.apply_filters

      assert_equal filtered_scope, filter.documents
    end

    test "date and direction param allows filtering before a date" do
      document_scope.expects(:published_before).with(Date.parse("2012-01-01 12:23:45")).returns(document_scope)
      filter = Whitehall::DocumentFilter::Mysql.new( date: "2012-01-01 12:23:45", direction: "before")
      filter.documents = document_scope
      filter.apply_filters
    end

    test "direction before a date returns documents in reverse chronological order" do
      document_scope.expects(:in_reverse_chronological_order).returns(document_scope)
      filter = Whitehall::DocumentFilter::Mysql.new( date: "2012-01-01 12:23:45", direction: "before")
      filter.documents = document_scope
      filter.apply_filters
    end

    test "direction param sets direction attribute" do
      assert_equal "before", Whitehall::DocumentFilter::Mysql.new( direction: "before").direction
    end

    test "date param sets date attribute" do
      assert_equal Date.parse("2012-01-01 12:23:45"), Whitehall::DocumentFilter::Mysql.new( date: "2012-01-01 12:23:45").date
    end

    test "invalid date param sets date attribute to nil" do
      assert_equal nil, Whitehall::DocumentFilter::Mysql.new( date: "invalid-date").date
    end

    test "can filter after a date" do
      document_scope.expects(:published_after).with(Date.parse("2012-01-01 12:23:45")).returns(document_scope)
      filter = Whitehall::DocumentFilter::Mysql.new(date: "2012-01-01 12:23:45", direction: "after")
      filter.documents = document_scope
      filter.apply_filters
    end

    test "filtering after a date returns documents in chronological order" do
      document_scope.expects(:in_chronological_order).returns(document_scope)
      filter = Whitehall::DocumentFilter::Mysql.new(date: "2012-01-01 12:23:45", direction: "after")
      filter.documents = document_scope
      filter.apply_filters
    end

    test "publication_type param filters by publication type" do
      publication_filter_option = stub_publication_filter_option("testing filter - statistics", publication_types: [stub('type', id: 123)])

      filtered_scope = stub_document_scope('filtered_scope')
      document_scope.expects(:where).with(publication_type_id: [123]).returns(filtered_scope)

      filter = Whitehall::DocumentFilter::Mysql.new( publication_filter_option: publication_filter_option.slug)
      filter.documents = document_scope
      filter.apply_filters
      assert_equal filtered_scope, filter.documents
    end

    test "publication_type param can also filter by publication edition type" do
      publication_filter_option = stub_publication_filter_option("testing filter - statistics", publication_types: [stub('type', id: 123), stub('other type', id: 234)], edition_types: ["EditionType"])

      filtered_scope = stub_document_scope('filtered_scope')
      expected_query = "(`editions`.`publication_type_id` IN (123, 234) OR `editions`.`type` IN ('EditionType'))"
      document_scope.expects(:where).with(responds_with(:to_sql, expected_query)).returns(filtered_scope)

      filter = Whitehall::DocumentFilter::Mysql.new( publication_filter_option: publication_filter_option.slug)
      filter.documents = document_scope
      filter.apply_filters
      assert_equal filtered_scope, filter.documents
    end

    test "publication_filter_option param sets #selected_publication_filter_option" do
      publication_filter_option = stub_publication_filter_option("testing filter option - statistics")

      filter = Whitehall::DocumentFilter::Mysql.new( publication_filter_option: publication_filter_option.slug)
      filter.documents = document_scope
      filter.apply_filters

      assert_equal publication_filter_option, filter.selected_publication_filter_option
    end

    test "publication_type param also sets #selected_publication_filter_option to keep old links working" do
      publication_filter_option = stub_publication_filter_option("testing filter option - statistics")
      filter = Whitehall::DocumentFilter::Mysql.new( publication_type: publication_filter_option.slug)
      filter.documents = document_scope
      filter.apply_filters

      assert_equal publication_filter_option, filter.selected_publication_filter_option
    end

    test "can filter announcements by location" do
      world_location = create(:world_location)
      other_world_location = create(:world_location)

      news_article = create(:published_news_article, news_article_type: NewsArticleType::NewsStory, world_locations: [world_location])
      fatality_notice = create(:published_fatality_notice, world_locations: [world_location])
      transcript = create(:published_speech, speech_type: SpeechType::Transcript, world_locations: [world_location])
      statement = create(:published_speech, speech_type: SpeechType::WrittenStatement, world_locations: [other_world_location])

      assert_equal 4, Whitehall::DocumentFilter::Mysql.new(Announcement.published, locations: [world_location.slug, other_world_location.slug]).documents.count
      assert_equal 3, Whitehall::DocumentFilter::Mysql.new(Announcement.published, locations: [world_location.slug]).documents.count
      assert_equal 1, Whitehall::DocumentFilter::Mysql.new(Announcement.published, locations: [other_world_location.slug]).documents.count
    end

    test "can filter announcements by type" do
      news_article = create(:published_news_article, news_article_type: NewsArticleType::NewsStory)
      fatality_notice = create(:published_fatality_notice)
      transcript = create(:published_speech, speech_type: SpeechType::Transcript)
      statement = create(:published_speech, speech_type: SpeechType::WrittenStatement)

      filter = Whitehall::DocumentFilter::Mysql.new(announcement_type_option: "news-stories")
      filter.documents = Announcement.published
      filter.apply_filters
      assert_equal [news_article.id], filter.documents.map(&:id)
      
      filter = Whitehall::DocumentFilter::Mysql.new(announcement_type_option: "fatality-notices")
      filter.documents = Announcement.published
      filter.apply_filters
      assert_equal [fatality_notice.id], filter.documents.map(&:id)

      filter = Whitehall::DocumentFilter::Mysql.new(announcement_type_option: "speeches")
      filter.documents = Announcement.published
      filter.apply_filters
      assert_equal [transcript.id], filter.documents.map(&:id)
      
      filter = Whitehall::DocumentFilter::Mysql.new(announcement_type_option: "statements")
      filter.documents = Announcement.published
      filter.apply_filters
      assert_equal [statement.id], filter.documents.map(&:id)
    end

    test "publication_filter_option overwrites older publication_type param" do
      publication_filter_option = stub_publication_filter_option("testing filter option - statistics")
      filter = Whitehall::DocumentFilter::Mysql.new(publication_type: 'foobar', publication_filter_option: publication_filter_option.slug)
      filter.documents = document_scope
      filter.apply_filters

      assert_equal publication_filter_option, filter.selected_publication_filter_option
    end

    test "if page param given, returns a page of documents using page size of 20" do
      document_scope.expects(:page).with(3).returns(document_scope)
      document_scope.expects(:per).with(20).returns(document_scope)
      with_number_of_documents_per_page(20) do
        filter = Whitehall::DocumentFilter::Mysql.new( page: 3)
        filter.documents = document_scope
        filter.apply_filters
      end
    end

    test "allows combination of filter options" do
      organisation = stub_organisation('defra')
      topic = stub_topic("car-tax")

      document_scope.expects(:in_organisation).with([organisation]).returns(document_scope)
      document_scope.expects(:published_in_topic).with([topic]).returns(document_scope)
      document_scope.expects(:page).with(2).returns(document_scope)

      filter = Whitehall::DocumentFilter::Mysql.new(
        departments: [organisation.slug],
        topics: [topic.slug],
        page: 2)
      filter.documents = document_scope
      filter.apply_filters


      assert_equal [organisation], filter.selected_organisations
      assert_equal [topic], filter.selected_topics
    end

    test "avoids loading the wrong document when combining topic and department filter" do
      organisation = create(:organisation)
      policy = create(:published_policy)
      topic = create(:topic, policies: [policy])
      news_article = create(:published_news_article, related_policies: [policy], organisations: [organisation])

      document_scope = Announcement.published.includes(:document, :organisations)
      filter = Whitehall::DocumentFilter::Mysql.new(
        departments: [organisation.slug],
        topics: [topic.slug],
        page: 1)
      filter.documents = document_scope
      filter.apply_filters

      assert_equal news_article.document_id, filter.documents.first.document.id
    end

    test 'does not use n+1 selects when filtering by topics' do
      policy = create(:published_policy)
      topic = create(:topic, policies: [policy])
      3.times { create(:published_publication, related_policies: [policy]) }
      queries = count_queries { 
        filter = Whitehall::DocumentFilter::Mysql.new(topics: [topic.slug])
        filter.documents = Publication.published
        filter.apply_filters
        filter.documents
      }
      assert 3 > queries
    end

    test 'does not use n+1 selects when filtering by organisations' do
      organisation = create(:organisation)
      3.times { create(:published_publication, organisations: [organisation]) }
      queries = count_queries {
        filter = Whitehall::DocumentFilter::Mysql.new(departments: [organisation.slug])
        filter.documents = Publication.published
        filter.apply_filters
        filter.documents
      }
      assert 3 > queries
    end

    test 'does not use n+1 selects when filtering by keywords' do
      3.times { |i| create(:published_publication, title: "keyword-#{i}") }
      queries = count_queries { 
        filter = Whitehall::DocumentFilter::Mysql.new(keywords: "keyword")
        filter.documents = Publication.published
        filter.apply_filters
        filter.documents
      }
      assert 3 > queries
    end

    test 'does not use n+1 selects when filtering by date' do
      3.times { |i| create(:published_publication, publication_date: i.months.ago) }
      queries = count_queries {
        filter = Whitehall::DocumentFilter::Mysql.new(date: "2012-01-01 12:23:45", direction: "before")
        filter.documents = Publication.published
        filter.apply_filters
        filter.documents
      }
      assert 3 > queries
    end

    test "can filter announcements by topic" do
      policy = create(:published_policy)
      topic = create(:topic, policies: [policy])
      create(:published_speech, related_policies: [policy])
      create(:published_news_article, related_policies: [policy])
      create(:published_speech)
      create(:published_news_article)
      unfiltered_announcements = Announcement.published
      filter = Whitehall::DocumentFilter::Mysql.new(topics: [topic.slug])
      filter.documents = unfiltered_announcements
      filter.apply_filters

      assert_equal 2, filter.documents.count
    end

    # def self.test_delegates_to_documents(method)
    #   test "delegates ##{method} to documents" do
    #     document_scope.expects(method)
    #     Whitehall::DocumentFilter::Mysql.new(document_scope).send(method)
    #   end
    # end
    # 
    # test_delegates_to_documents(:count)
    # test_delegates_to_documents(:num_pages)
    # test_delegates_to_documents(:current_page)
    # test_delegates_to_documents(:last_page?)
    # test_delegates_to_documents(:first_page?)

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
      document_scope.stubs(:with_title_or_summary_containing).returns(document_scope)
      document_scope.stubs(:published_before).returns(document_scope)
      document_scope.stubs(:published_after).returns(document_scope)
      document_scope.stubs(:alphabetical).returns(document_scope)
      document_scope.stubs(:published_in_topic).returns(document_scope)
      document_scope.stubs(:in_organisation).returns(document_scope)
      document_scope.stubs(:where).with(has_entry(:publication_type_id, anything)).returns(document_scope)
      document_scope.stubs(:where).with(has_entry(:relevant_to_local_government, anything)).returns(document_scope)
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
end
