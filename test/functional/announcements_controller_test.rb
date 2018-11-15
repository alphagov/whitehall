require "test_helper"
require "gds_api/test_helpers/content_store"

class AnnouncementsControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper
  include DocumentFilterHelpers
  include GdsApi::TestHelpers::ContentStore
  include TaxonomyHelper

  should_be_a_public_facing_controller
  should_return_json_suitable_for_the_document_filter :news_article
  should_return_json_suitable_for_the_document_filter :speech

  setup do
    @rummager = stub
    @content_item = content_item_for_base_path(
      '/government/announcements'
    )

    content_store_has_item(@content_item['base_path'], @content_item)
    stub_taxonomy_with_all_taxons
  end

  view_test "index shows a mix of news and speeches" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' =>
                                           [{ 'format' => 'news_article', 'content_id' => 'news_id', 'public_timestamp' => Time.zone.now.to_s },
                                            { 'format' => 'speech', 'content_id' => 'speech_id', 'public_timestamp' => Time.zone.now.to_s }])

      get :index

      assert_select '#news_article_news_id'
      assert_select '#speech_speech_id'
    end
  end

  test "index sets Cache-Control: max-age to the time of the next scheduled publication" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search)
      create(:scheduled_news_article, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)

      Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
        get :index
      end

      assert_cache_control("max-age=#{Whitehall.default_cache_max_age / 2}")
    end
  end

  view_test "index shows which type a record is" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' =>
                                           [{ 'format' => 'news_story', 'content_id' => 'news_id', 'display_type' => 'News story', 'public_timestamp' => Time.zone.now.to_s },
                                            { 'format' => 'speech', 'content_id' => 'speech_id', 'display_type' => 'Speech', 'public_timestamp' => Time.zone.now.to_s },
                                            { 'format' => 'written_statement', 'content_id' => 'written_statement_id', 'display_type' => 'Statement to Parliament', 'public_timestamp' => Time.zone.now.to_s }])

      get :index

      assert_select '#news_story_news_id' do
        assert_select ".display-type", text: "News story"
      end
      assert_select '#speech_speech_id' do
        assert_select ".display-type", text: "Speech"
      end
      assert_select '#written_statement_written_statement_id' do
        assert_select ".display-type", text: "Statement to parliament"
      end
    end
  end

  view_test "index shows the date on which a speech was first published" do
    with_stubbed_rummager(@rummager, true) do
      first_published_at = Date.parse("1999-12-31").to_datetime.iso8601
      @rummager.expects(:search).returns('results' =>
                                          [{ 'format' => 'speech',
                                             'content_id' => 'speech_id',
                                             'public_timestamp' => first_published_at }])
      get :index

      assert_select '#speech_speech_id' do
        assert_select "time.public_timestamp[datetime=?]", first_published_at
      end
    end
  end

  view_test "index shows the time when a news article was first published" do
    with_stubbed_rummager(@rummager, true) do
      first_published_at = Time.zone.parse("2001-01-01 01:01").iso8601
      content_id = SecureRandom.uuid
      @rummager.expects(:search).returns('results' =>
                                            [{ 'format' => 'speech',
                                               'content_id' => content_id,
                                               'public_timestamp' => first_published_at }])
      get :index

      assert_select "#speech_#{content_id}" do
        assert_select "time.public_timestamp[datetime=?]", first_published_at
      end
    end
  end

  view_test "index shows related organisations for each type of article" do
    with_stubbed_rummager(@rummager, true) do
      first_org = create(:organisation, name: 'first-org', acronym: "FO")
      second_org = create(:organisation, name: 'second-org', acronym: "SO")

      @rummager.expects(:search).returns('results' =>
                                          [{ 'format' => 'news_article',
                                             'content_id' => 'news_id',
                                             'organisations' =>
                                               [{ 'acronym' => first_org.acronym },
                                                { 'acronym' => second_org.acronym }],
                                              'public_timestamp' => Time.zone.now.to_s },
                                           { 'format' => 'speech',
                                             'content_id' => 'speech_id',
                                             'organisations' =>
                                               [{ 'acronym' => second_org.acronym }],
                                             'public_timestamp' => Time.zone.now.to_s }])

      get :index

      assert_select '#news_article_news_id' do
        assert_select ".organisations", text: "FO and SO", count: 1
      end

      assert_select '#speech_speech_id' do
        assert_select ".organisations", text: "SO", count: 1
      end
    end
  end

  view_test "index shows articles in reverse chronological order" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).with(has_entry(order: '-public_timestamp')).returns(
        'results' =>
          [{ 'format' => 'published_speech', 'content_id' => 'new_id', 'public_timestamp' => Time.zone.now.to_s },
           { 'format' => 'published_news_article', 'content_id' => 'old_id', 'public_timestamp' => Time.zone.now.to_s }]
      )

      get :index

      assert_select '#published_speech_new_id + #published_news_article_old_id'
    end
  end

  view_test "index shows selected announcement type filter option in the title" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [])
      get :index, params: { announcement_filter_option: 'news-stories' }

      assert_select 'h1 span', ': news stories'
    end
  end

  view_test "index indicates selected announcement type filter option in the filter selector" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [{ 'format' => 'news_article', 'public_timestamp' => Time.zone.now.to_s }])
      get :index, params: { announcement_filter_option: 'news-stories' }

      assert_select "select[name='announcement_filter_option']" do
        assert_select "option[selected='selected']", text: Whitehall::AnnouncementFilterOption::NewsStory.label
      end
    end
  end

  view_test "index indicates selected world location in the filter selector" do
    with_stubbed_rummager(@rummager, true) do
      world_location_1 = create(:world_location, name: "Afghanistan")
      world_location_2 = create(:world_location, name: "Albania")
      world_location_3 = create(:world_location, name: "Algeria")
      create(:published_news_article, world_locations: [world_location_1, world_location_2, world_location_3])

      @rummager.expects(:search).returns('results' =>
        [{ "format" => 'news_article', "world_locations" => [{ slug: world_location_1.slug }, { slug: world_location_3.slug }], 'public_timestamp' => Time.zone.now.to_s }])

      get :index, params: { world_locations: [world_location_1.slug, world_location_3.slug] }

      assert_select "select[name='world_locations[]']" do
        assert_select "option[selected='selected']", count: 2
      end
    end
  end

  view_test "index indicates selected people in the filter selector" do
    with_stubbed_rummager(@rummager, true) do
      a_person = create(:person, forename: "Jane", surname: "Doe")
      @rummager.expects(:search).returns('results' => [{ "format" => "news_article", "people" => [{ "slug" => a_person.slug }], "public_timestamp" => Time.zone.now.to_s }])
      get :index, params: { people: [a_person.slug] }

      assert_select "select[name='people[]']" do
        assert_select "option[selected='selected']", text: "Jane Doe"
      end
    end
  end

  def assert_documents_appear_in_order_within(containing_selector, expected_documents)
    articles = css_select "#{containing_selector} li.document-row"
    expected_document_ids = expected_documents.map { |doc| "#{doc['format']}_#{doc['content_id']}" }
    actual_document_ids = articles.map { |a| a["id"] }
    assert_equal expected_document_ids, actual_document_ids
  end

  def refute_select(hash)
    assert_select "#{hash['format']}_#{hash['content_id']}", count: 0
  end

  view_test "index shows only the first page of news articles or speeches" do
    with_stubbed_rummager(@rummager, true) do
      news = (1..2).map { |n| { 'format' => 'news_article', 'content_id' => n, 'public_timestamp' => Time.zone.now.to_s } }
      speeches = (3..4).map { |n| { 'format' => 'published_speech', 'content_id' => n, 'public_timestamp' => Time.zone.now.to_s } }

      @rummager.expects(:search).returns('results' => news + speeches)

      with_number_of_documents_per_page(3) do
        get :index
      end

      assert_documents_appear_in_order_within(".filter-results", news + speeches[0..0])

      (speeches[1..2]).each do |speech|
        refute_select(speech)
      end
    end
  end

  view_test "index shows the requested page" do
    with_stubbed_rummager(@rummager, true) do
      news = (1..3).map { |n| { 'format' => 'news_article', 'content_id' => n, 'public_timestamp' => Time.zone.now.to_s } }
      speeches = (4..6).map { |n| { 'format' => 'published_speech', 'content_id' => n, 'public_timestamp' => Time.zone.now.to_s } }

      @rummager.expects(:search).returns('results' => news + speeches)

      with_number_of_documents_per_page(4) do
        get :index, params: { page: 2 }
      end

      assert_documents_appear_in_order_within(".filter-results", speeches[1..2])
      (news + speeches[0..0]).each do |speech|
        refute_select(speech)
      end
    end
  end

  view_test "#index highlights selected taxon filter options" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [{ 'format' => 'news_article', 'part_of_taxonomy_tree' => [root_taxon['content_id']], 'public_timestamp' => Time.zone.now.to_s }])
      get :index, params: { taxons: [root_taxon['content_id']] }

      assert_select "select#taxons[name='taxons[]']" do
        assert_select "option[selected='selected']", text: root_taxon['title']
      end
    end
  end

  view_test "#index highlights all taxons filter options by default" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [])
      get :index

      assert_select "select[name='taxons[]']" do
        assert_select "option[selected='selected']", text: "All topics"
      end
    end
  end

  view_test 'index has atom feed autodiscovery link' do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [])
      get :index
      assert_select_autodiscovery_link announcements_url(format: "atom", host: Whitehall.public_host, protocol: Whitehall.public_protocol)
    end
  end

  view_test 'index atom feed autodiscovery link includes any present filters' do
    with_stubbed_rummager(@rummager, true) do
      topic = create(:topic)
      organisation = create(:organisation)

      @rummager.expects(:search).returns('results' => [{ "format" => 'news_article',
                                                         "organisations" => [{ "slug" => organisation.slug }],
                                                         "topics" => [{ "slug" => topic.slug }],
                                                         "public_timestamp" => Time.zone.now.to_s }])

      get :index, params: { topics: [topic], departments: [organisation] }

      assert_select_autodiscovery_link announcements_url(format: "atom", topics: [topic], departments: [organisation], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
    end
  end

  view_test "index generates an atom feed for the current filter" do
    with_stubbed_rummager(@rummager, true) do
      org = create(:organisation, name: "org-name")

      rummager_results_with_org = {
        "results" => [
            {
            "link": "/foo/news_story",
            "title": "PM attends summit on topical events",
            "public_timestamp": "2018-10-07T22:18:32Z",
            "display_type": "news_article",
            "description": "Description of document...",
            "content_id": "1234-C",
            "organisations": [
              {
                "slug": org.slug
              }
            ]
          }
        ]
      }.with_indifferent_access

      @rummager.expects(:search).returns(rummager_results_with_org)

      get :index, params: { departments: [org.to_param] }, format: :atom

      assert_select_atom_feed do
        assert_select 'feed > id', 1
        assert_select 'feed > title', 1
        assert_select 'feed > author, feed > entry > author'
        assert_select 'feed > updated', 1
        assert_select 'feed > link[rel=?][type=?][href=?]', 'self', 'application/atom+xml',
        announcements_url(format: :atom, departments: [org.to_param]), 1
        assert_select 'feed > link[rel=?][type=?][href=?]', 'alternate', 'text/html', root_url, 1
      end
    end
  end

  view_test "index generates an atom feed with entries for announcements matching the current filter" do
    with_stubbed_rummager(@rummager, true) do
      org = create(:organisation, name: "org-name")
      create(:published_news_article, organisations: [org], first_published_at: 1.week.ago)

      @rummager.expects(:search).returns(search_results_from_rummager)

      processed_rummager_documents = search_results_from_rummager['results'].map do |result|
        RummagerDocumentPresenter.new(result)
      end

      get :index, params: { departments: [org.to_param] }, format: :atom

      assert_select_atom_feed do
        assert_select_atom_entries(processed_rummager_documents, false)
      end
    end
  end

  view_test "index generates an atom feed with the legacy announcement_type_option param set" do
    with_stubbed_rummager(@rummager, true) do
      create(:published_news_story, first_published_at: 1.week.ago)

      @rummager.expects(:search).returns(search_results_from_rummager)

      processed_rummager_documents = search_results_from_rummager['results'].map do |result|
        RummagerDocumentPresenter.new(result)
      end

      get :index, params: { announcement_type_option: 'news-stories' }, format: :atom

      assert_select_atom_feed do
        assert_select_atom_entries(processed_rummager_documents, false)
      end
    end
  end

  view_test 'index atom feed should return a valid feed if there are no matching documents' do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [])
      get :index, format: :atom

      assert_select_atom_feed do
        assert_select 'feed > updated', text: Time.zone.now.iso8601
        assert_select 'feed > entry', count: 0
      end
    end
  end

  view_test "index requested as JSON includes email signup path with organisation and topic parameters" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [])
      topic = create(:topic)
      organisation = create(:organisation)

      get :index, params: { to_date: "2012-01-01", topics: [topic.slug], departments: [organisation.slug] }, format: :json

      json = ActiveSupport::JSON.decode(response.body)
      atom_url = announcements_url(format: "atom", topics: [topic.slug], departments: [organisation.slug], host: Whitehall.public_host, protocol: Whitehall.public_protocol)

      assert_equal json["email_signup_url"], new_email_signups_path(email_signup: { feed: atom_url })
    end
  end

  view_test 'index only lists documents in the given locale' do
    news = create(:published_news_article, translated_into: [:fr])
    get :index, params: { locale: 'fr' }

    assert_select "#news_article_#{news.id}"
  end

  view_test 'index for non-english locale copes when a nil page is specified' do
    create(:published_news_article)
    create(:published_news_article, translated_into: [:fr])
    get :index, params: { locale: 'fr', page: nil }

    assert_response :success
  end

  view_test 'index for non-english locales only allows filtering by world location' do
    get :index, params: { locale: 'fr' }

    assert_select '.filter', count: 1
    assert_select "select#world_locations"
  end

  view_test 'index for non-english locales skips results summary' do
    get :index, params: { locale: 'fr' }
    refute_select '.filter-results-summary'
  end

  view_test 'index includes tracking details on all links' do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' =>
                                          [{ 'format' => 'published_news_article',
                                             'content_id' => 'news_id',
                                             'link' => '/path/to/somewhere',
                                             'title' => 'title',
                                             'public_timestamp' => Time.zone.now.to_s }])

      get :index

      assert_select '#published_news_article_news_id' do
        results_list = css_select('ol.document-list').first

        assert_equal(
          'track-click',
          results_list.attributes['data-module'].value,
          "Expected the document list to have the 'track-click' module"
        )

        article_link = css_select('li.document-row a').first

        assert_equal(
          'navAnnouncementLinkClicked',
          article_link.attributes['data-category'].value,
          "Expected the data category attribute to be 'navAnnouncementLinkClicked'"
        )

        assert_equal(
          '1',
          article_link.attributes['data-action'].value,
          "Expected the data action attribute to be the 1st position on the list"
        )

        assert_equal(
          '/path/to/somewhere',
          article_link.attributes['data-label'].value,
          "Expected the data label attribute to be the link of the news article"
        )

        options = JSON.parse(article_link.attributes['data-options'].value)

        assert_equal(
          '1',
          options['dimension28'],
          "Expected the custom dimension 28 to have the total number of articles"
        )

        assert_equal(
          'title',
          options['dimension29'],
          "Expected the custom dimension 29 to have the title of the article"
        )
      end
    end
  end

  def search_results_from_rummager
    {
      "results" => [
          {
          "link": "/foo/news_story",
          "title": "PM attends summit on topical events",
          "public_timestamp": "2018-10-07T22:18:32Z",
          "display_type": "news_article",
          "description": "Description of document...",
          "content_id": "1234-C"
        }
      ]
    }.with_indifferent_access
  end
end
