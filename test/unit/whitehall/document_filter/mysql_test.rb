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

    test "topics param filters the documents by topic using slugs" do
      topic = stub_topic("car-tax")

      filtered_scope = stub_document_scope('filtered_scope')
      document_scope.expects(:published_in_topic).with([topic]).returns(filtered_scope)

      filter = create_filter(document_scope, topics: [topic.slug])

      assert_equal filtered_scope, filter.documents
    end

    test "topics param sets #selected_topics" do
      topic = stub_topic("car-tax")

      filtered_scope = stub_document_scope('filtered_scope')
      document_scope.stubs(:published_in_topic).with([topic]).returns(filtered_scope)

      filter = create_filter(document_scope, topics: [topic.slug])

      assert_equal [topic], filter.selected_topics
    end

    test "topics param does not filter if topics are not present" do
      document_scope.expects(:published_in_topic).never

      filter = create_filter(document_scope, topics: "")

      assert_equal document_scope, filter.documents
    end

    test "topics param does not filter if topic is 'all'" do
      document_scope.expects(:published_in_topic).never

      filter = create_filter(document_scope, topics: ['all'])

      assert_equal document_scope, filter.documents
    end

    test "departments param filters the documents by organisation using slugs" do
      organisation = stub_organisation('defra')

      filtered_scope = stub_document_scope('filtered_scope')
      document_scope.stubs(:in_organisation).with([organisation]).returns(filtered_scope)

      filter = create_filter(document_scope, departments: [organisation.slug])

      assert_equal filtered_scope, filter.documents
    end

    test "departments param sets #selected_organisations" do
      organisation = stub_organisation('defra')

      filter = create_filter(document_scope, departments: [organisation.slug])

      assert_equal [organisation], filter.selected_organisations
    end

    test "does not filter if departments are not present" do
      document_scope.expects(:in_organisation).never
      create_filter(document_scope, departments: "")
    end

    test "does not filter if departments is 'all'" do
      document_scope.expects(:in_organisation).never
      create_filter(document_scope, departments: ['all'])
    end

    test "keywords param filters by content containing each keyword" do
      filtered_scope = stub_document_scope('filtered scope')
      document_scope.expects(:with_title_or_summary_containing).with("alpha", "beta").returns(filtered_scope)

      filter = create_filter(document_scope, keywords: "alpha beta")

      assert_equal filtered_scope, filter.documents
    end

    test "keywords param sets the keywords attribute" do
      filter = Whitehall::DocumentFilter::Mysql.new(keywords: "alpha beta")
      assert_equal %w(alpha beta), filter.keywords
    end

    test "keywords param does not filter if no keywords were given" do
      document_scope.expects(:with_title_or_summary_containing).never
      create_filter(document_scope, keywords: '')
    end

    test "locale param filters content by locale" do
      filtered_scope = stub_document_scope('filtered scope')
      document_scope.expects(:with_translations).with("fr").returns(filtered_scope)
      filter = create_filter(document_scope, locale: "fr")
    end

    test "locale param does not filter if no locale given" do
      document_scope.expects(:with_translations).never
      create_filter(document_scope, {})
    end

    test "strips leading and trailing spaces from keywords" do
      filtered_scope = stub_document_scope('filtered scope')
      document_scope.expects(:with_title_or_summary_containing).with("alpha", "beta").returns(filtered_scope)
      filter = create_filter(document_scope, keywords: " alpha   beta ")

      assert_equal filtered_scope, filter.documents
    end

    test "date param allows filtering after a date" do
      document_scope.expects(:published_after).with(Chronic.parse("2012-01-01 12:23:45").to_date).returns(document_scope)
      create_filter(document_scope, from_date: "2012-01-01 12:23:45")
    end

    test "date param allows filtering before a date" do
      document_scope.expects(:published_before).with(Chronic.parse("2012-01-01 12:23:45").to_date).returns(document_scope)
      create_filter(document_scope, to_date: "2012-01-01 12:23:45")
    end

    test "date param sets date attribute" do
      assert_equal Chronic.parse("2012-01-01 12:23:45").to_date, Whitehall::DocumentFilter::Mysql.new(from_date: "2012-01-01 12:23:45").from_date
      assert_equal Chronic.parse("2012-01-01 12:23:45").to_date, Whitehall::DocumentFilter::Mysql.new(to_date: "2012-01-01 12:23:45").to_date
    end

    test "invalid date param sets date attribute to nil" do
      assert_equal nil, Whitehall::DocumentFilter::Mysql.new(from_date: "invalid-date").from_date
    end

    test "publication_type param filters by publication type" do
      publication_filter_option = stub_publication_filter_option("testing filter - statistics", publication_types: [stub('type', id: 123)])

      filtered_scope = stub_document_scope('filtered_scope')
      document_scope.expects(:where).with(publication_type_id: [123]).returns(filtered_scope)

      filter = create_filter(document_scope, publication_filter_option: publication_filter_option.slug)
      assert_equal filtered_scope, filter.documents
    end

    test "publication_type param can also filter by publication edition type" do
      publication_filter_option = stub_publication_filter_option("testing filter - statistics", publication_types: [stub('type', id: 123), stub('other type', id: 234)], edition_types: ["EditionType"])

      filtered_scope = stub_document_scope('filtered_scope')
      expected_query = "(`editions`.`publication_type_id` IN (123, 234) OR `editions`.`type` IN ('EditionType'))"
      document_scope.expects(:where).with(responds_with(:to_sql, expected_query)).returns(filtered_scope)

      filter = create_filter(document_scope, publication_filter_option: publication_filter_option.slug)
      assert_equal filtered_scope, filter.documents
    end

    test "publication_filter_option param sets #selected_publication_filter_option" do
      publication_filter_option = stub_publication_filter_option("testing filter option - statistics")
      filter = create_filter(document_scope, publication_filter_option: publication_filter_option.slug)

      assert_equal publication_filter_option, filter.selected_publication_filter_option
    end

    test "publication_type param also sets #selected_publication_filter_option to keep old links working" do
      publication_filter_option = stub_publication_filter_option("testing filter option - statistics")
      filter = create_filter(document_scope, publication_type: publication_filter_option.slug)

      assert_equal publication_filter_option, filter.selected_publication_filter_option
    end

    test "can filter publications by location" do
      world_location = create(:world_location)
      other_world_location = create(:world_location)

      item_1 = create(:published_publication, world_locations: [world_location])
      item_2 = create(:published_statistical_data_set)
      item_3 = create(:published_publication, world_locations: [other_world_location])
      item_4 = create(:published_consultation)

      filter = Whitehall::DocumentFilter::Mysql.new(world_locations: [world_location.slug, other_world_location.slug])
      filter.publications_search
      assert_same_elements [item_1, item_3], filter.documents

      filter = Whitehall::DocumentFilter::Mysql.new(world_locations: [world_location.slug])
      filter.publications_search
      assert_same_elements [item_1], filter.documents

      filter = Whitehall::DocumentFilter::Mysql.new(world_locations: [])
      filter.publications_search
      assert_same_elements [item_1, item_2, item_3, item_4], filter.documents
    end

    test "can filter consultations" do
      publication  = create(:published_publication)
      consultation = create(:published_consultation)
      filter = Whitehall::DocumentFilter::Mysql.new(publication_filter_option: 'consultations')
      filter.publications_search

      assert_equal [consultation], filter.documents
    end

    test "can filter announcements by location" do
      world_location = create(:world_location)
      other_world_location = create(:world_location)

      news_article = create(:published_news_article, news_article_type: NewsArticleType::NewsStory, world_locations: [world_location])
      fatality_notice = create(:published_fatality_notice, world_locations: [world_location])
      transcript = create(:published_speech, speech_type: SpeechType::Transcript, world_locations: [world_location])
      statement = create(:published_speech, speech_type: SpeechType::WrittenStatement, world_locations: [other_world_location])

      assert_equal 4, create_filter(Announcement.published, world_locations: [world_location.slug, other_world_location.slug]).documents.count
      assert_equal 3, create_filter(Announcement.published, world_locations: [world_location.slug]).documents.count
      assert_equal 1, create_filter(Announcement.published, world_locations: [other_world_location.slug]).documents.count
    end

    test "can filter announcements by type" do
      news_article = create(:published_news_article, news_article_type: NewsArticleType::NewsStory)
      fatality_notice = create(:published_fatality_notice)
      transcript = create(:published_speech, speech_type: SpeechType::Transcript)
      statement = create(:published_speech, speech_type: SpeechType::WrittenStatement)

      filter = create_filter(Announcement.published, announcement_type_option: "news-stories")
      assert_equal [news_article.id], filter.documents.map(&:id)

      filter = create_filter(Announcement.published, announcement_type_option: "fatality-notices")
      assert_equal [fatality_notice.id], filter.documents.map(&:id)

      filter = create_filter(Announcement.published, announcement_type_option: "speeches")
      assert_equal [transcript.id], filter.documents.map(&:id)

      filter = create_filter(Announcement.published, announcement_type_option: "statements")
      assert_equal [statement.id], filter.documents.map(&:id)
    end

    test "publication_filter_option overwrites older publication_type param" do
      publication_filter_option = stub_publication_filter_option("testing filter option - statistics")
      filter = create_filter(document_scope, publication_type: 'foobar', publication_filter_option: publication_filter_option.slug)

      assert_equal publication_filter_option, filter.selected_publication_filter_option
    end

    test "if page param given, returns a page of documents using page size of 20" do
      document_scope.expects(:page).with(3).returns(document_scope)
      document_scope.expects(:per).with(20).returns(document_scope)
      with_number_of_documents_per_page(20) do
        create_filter(document_scope, page: 3)
      end
    end

    test "allows combination of filter options" do
      organisation = stub_organisation('defra')
      topic = stub_topic("car-tax")

      document_scope.expects(:in_organisation).with([organisation]).returns(document_scope)
      document_scope.expects(:published_in_topic).with([topic]).returns(document_scope)
      document_scope.expects(:page).with(2).returns(document_scope)

      filter = create_filter(document_scope,
        departments: [organisation.slug],
        topics: [topic.slug],
        page: 2)

      assert_equal [organisation], filter.selected_organisations
      assert_equal [topic], filter.selected_topics
    end

    test "avoids loading the wrong document when combining topic and department filter" do
      organisation = create(:organisation)
      topic = create(:topic)
      news_article = create(:published_news_article, topics: [topic], organisations: [organisation])

      document_scope = Announcement.published.includes(:document, :organisations)
      filter = create_filter(document_scope, departments: [organisation.slug], topics: [topic.slug], page: 1)

      assert_equal news_article.document_id, filter.documents.first.document.id
    end

    test "can filter announcements by topic" do
      topic = create(:topic)
      create(:published_speech, topics: [topic])
      create(:published_news_article, topics: [topic])
      create(:published_speech)
      create(:published_news_article)
      unfiltered_announcements = Announcement.published
      filter = create_filter(unfiltered_announcements, topics: [topic.slug])

      assert_equal 2, filter.documents.count
    end

    test "does not include WorldLocationNewsArticles by default" do
      create(:published_world_location_news_article)
      unfiltered_announcements = Announcement.published
      filter = create_filter(unfiltered_announcements, {})

      assert filter.documents.empty?
    end

    test "will include WorldLocationNewsArticles when explicitly asked to" do
      world_news = create(:published_world_location_news_article)
      unfiltered_announcements = Announcement.published
      filter = create_filter(unfiltered_announcements, include_world_location_news: '1')

      assert filter.documents.include?(world_news)
    end

    test 'will include all editions, including local government unless told otherwise' do
      policy_1 = create(:published_policy, :with_document, relevant_to_local_government: true)
      policy_2 = create(:published_policy, :with_document, relevant_to_local_government: false)
      publication_1 = create(:published_publication, related_policy_ids: [policy_1.id])
      publication_2 = create(:published_publication, related_policy_ids: [policy_2.id])
      unfiltered = Edition.published

      filter = create_filter(unfiltered, {})

      assert filter.documents.include?(policy_1)
      assert filter.documents.include?(policy_2)
      assert filter.documents.include?(publication_1)
      assert filter.documents.include?(publication_2)
    end

    test 'will reject all non-local government editions if asked to' do
      policy_1 = create(:published_policy, :with_document, relevant_to_local_government: true)
      policy_2 = create(:published_policy, :with_document, relevant_to_local_government: false)
      publication_1 = create(:published_publication, related_policy_ids: [policy_1.id])
      publication_2 = create(:published_publication, related_policy_ids: [policy_2.id])
      unfiltered = Edition.published

      filter = create_filter(unfiltered, relevant_to_local_government: '1')

      assert filter.documents.include?(policy_1)
      refute filter.documents.include?(policy_2)
      assert filter.documents.include?(publication_1)
      refute filter.documents.include?(publication_2)
    end

  private

    def create_filter(document_set, args)
      filter = Whitehall::DocumentFilter::Mysql.new(args)
      filter.documents = document_set
      filter.apply_filters
      filter
    end

    def document_scope
      @document_scope ||= stub_document_scope('unfiltered document scope')
    end

    def stub_document_scope(name)
      document_scope = stub(name,
        count: stub_everything,
        current_page: stub_everything,
        total_pages: stub_everything
      )
      document_scope.stubs(:arel_table).returns(Edition.arel_table)
      document_scope.stubs(:without_editions_of_type).returns(document_scope)
      document_scope.stubs(:in_reverse_chronological_order).returns(document_scope)
      document_scope.stubs(:with_title_or_summary_containing).returns(document_scope)
      document_scope.stubs(:published_before).returns(document_scope)
      document_scope.stubs(:published_after).returns(document_scope)
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
      Classification.stubs(:where).with(slug: [slug]).returns([topic])
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
