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

  test "when locale is english it redirects to news and communications" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [])

      get :index
      assert_response :redirect
    end
  end

  test "when locale is english it redirects with params for finder-frontend" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [])

      get :index, params: {
        keywords: "one two",
        taxons: %w[one],
        subtaxons: %w[two],
        people: %w[one two],
        departments: %w[one two],
        world_locations: %w[one two],
        from_date: '01/01/2014',
        to_date: '01/01/2014'
      }

      redirect_params_query = {
        keywords: "one two",
        level_one_taxon: 'one',
        level_two_taxon: 'two',
        people: %w[one two],
        organisations: %w[one two],
        world_locations: %w[one two],
        public_timestamp: { from: '01/01/2014', to: '01/01/2014' }
      }.to_query

      assert_redirected_to "#{Plek.new.website_root}/search/news-and-communications?#{redirect_params_query}"
    end
  end

  test "when locale is english it redirects and atom feed with params for finder-frontend" do
    with_stubbed_rummager(@rummager, true) do
      @rummager.expects(:search).returns('results' => [])

      get :index, params: {
        keywords: "one two",
        taxons: %w[one],
        subtaxons: %w[two],
        people: %w[one two],
        departments: {
          '0' => 'one',
          '1' => 'two',
        },
        world_locations: %w[one two],
        from_date: '01/01/2014',
        to_date: '01/01/2014'
      }, format: :atom

      redirect_params_query = {
        keywords: "one two",
        level_one_taxon: 'one',
        level_two_taxon: 'two',
        people: %w[one two],
        organisations: %w[one two],
        world_locations: %w[one two],
        public_timestamp: { from: '01/01/2014', to: '01/01/2014' }
      }.to_query

      assert_redirected_to "#{Plek.new.website_root}/search/news-and-communications.atom?#{redirect_params_query}"
    end
  end

  view_test "index with locale shows a mix of news and speeches" do
    news = create(:published_news_article, translated_into: [:fr])
    speech = create(:published_speech, translated_into: [:fr])
    get :index, params: { locale: 'fr' }

    assert_select "#news_article_#{news.id}"
    assert_select "#speech_#{speech.id}"
  end

  test "index with locale sets Cache-Control: max-age to the time of the next scheduled publication" do
    create(:scheduled_news_article, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :index, params: { locale: 'fr' }
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age / 2}")
  end

  view_test "index with locale shows which type a record is" do
    news = create(:published_news_story, translated_into: [:fr], news_article_type: NewsArticleType::NewsStory)
    speech = create(:published_speech, translated_into: [:fr])
    written_statement = create(:published_speech, translated_into: [:fr], speech_type: SpeechType::WrittenStatement)

    get :index, params: { locale: 'fr' }

    assert_select "#news_article_#{news.id}" do
      assert_select ".display-type", text: "News story"
    end
    assert_select "#speech_#{speech.id}" do
      assert_select ".display-type", text: "Speech"
    end
    assert_select "#speech_#{written_statement.id}" do
      assert_select ".display-type", text: "Statement to Parliament"
    end
  end

  view_test "index with locale shows the date on which a speech was first published" do
    first_published_at = Date.parse("1999-12-31").to_datetime.iso8601
    speech = create(:published_speech, first_published_at: first_published_at, translated_into: [:fr])

    get :index, params: { locale: 'fr' }

    assert_select "#speech_#{speech.id}" do
      assert_select "time.public_timestamp[datetime=?]", first_published_at
    end
  end

  view_test "index with locale shows the time when a news article was first published" do
    first_published_at = Date.parse("1999-12-31").to_datetime.iso8601
    news = create(:published_news_article, first_published_at: first_published_at, translated_into: [:fr])
    get :index, params: { locale: 'fr' }

    assert_select "#news_article_#{news.id}" do
      assert_select "time.public_timestamp[datetime=?]", first_published_at
    end
  end

  view_test "index shows related organisations for each type of article" do
    first_org = create(:organisation, name: 'first-org', acronym: "FO")
    second_org = create(:organisation, name: 'second-org', acronym: "SO")
    news = create(:published_news_story, translated_into: [:fr], organisations: [first_org, second_org])
    speech = create(:published_speech, translated_into: [:fr], organisations: [second_org])

    get :index, params: { locale: 'fr' }

    assert_select "#news_article_#{news.id}" do
      assert_select ".organisations", text: "FO et SO", count: 1
    end

    assert_select "#speech_#{speech.id}" do
      assert_select ".organisations", text: "SO", count: 1
    end
  end

  view_test "index with locale shows articles in reverse chronological order" do
    nineties = Date.parse("1999-12-31").to_datetime.iso8601
    twenty_first_century = Date.parse("2000-01-01").to_datetime.iso8601
    second_speech = create(:published_speech, first_published_at: twenty_first_century, translated_into: [:fr])
    first_speech = create(:published_speech, first_published_at: nineties, translated_into: [:fr])

    get :index, params: { locale: 'fr' }

    assert_select "#speech_#{second_speech.id} + #speech_#{first_speech.id}"
  end

  view_test "index with locale shows selected announcement type filter option in the title" do
    get :index, params: { announcement_filter_option: 'news-stories', locale: 'fr' }

    assert_select 'h1 span', ': news stories'
  end

  def assert_documents_appear_in_order_within(containing_selector, expected_documents)
    articles = css_select "#{containing_selector} li.document-row"
    expected_document_ids = expected_documents.map { |doc| "#{doc.display_type_key}_#{doc.id}" }
    actual_document_ids = articles.map { |a| a['id'] }
    assert_equal expected_document_ids, actual_document_ids
  end

  def refute_select(hash)
    assert_select "#{hash['format']}_#{hash['content_id']}", count: 0
  end

  view_test "index shows only the first page of news articles or speeches" do
    speeches = (1..2).map { create(:published_speech, translated_into: [:fr]) }
    news = (1..2).map { create(:published_news_article, translated_into: [:fr]) }

    with_number_of_documents_per_page(3) do
      get :index, params: { locale: 'fr' }
    end

    articles = css_select ".filter-results li.document-row"
    actual_document_ids = articles.map { |a| a['id'] }
    assert_equal [
      "news_article_#{news.second.id}",
      "news_article_#{news.first.id}",
      "speech_#{speeches.second.id}",
    ], actual_document_ids

    refute_select(speeches.first)
  end

  view_test "index shows the requested page" do
    speeches = (1..3).map { create(:published_speech, translated_into: [:fr]) }
    news = (1..3).map { create(:published_news_article, translated_into: [:fr]) }

    with_number_of_documents_per_page(4) do
      get :index, params: { page: 2, locale: 'fr' }
    end

    articles = css_select ".filter-results li.document-row"

    actual_document_ids = articles.map { |a| a['id'] }
    assert_equal [
      "speech_#{speeches.second.id}",
      "speech_#{speeches.first.id}",
    ], actual_document_ids

    (news + speeches[0..0]).each do |speech|
      refute_select(speech)
    end
  end

  view_test 'index has atom feed autodiscovery link' do
    get :index, params: { locale: 'fr' }
    assert_select_autodiscovery_link announcements_url(format: "atom", host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test 'index atom feed autodiscovery link includes any present filters' do
    topic = create(:topic)
    organisation = create(:organisation)

    get :index, params: { topics: [topic], departments: [organisation], locale: 'fr' }

    assert_select_autodiscovery_link announcements_url(format: "atom", topics: [topic], departments: [organisation], host: Whitehall.public_host, protocol: Whitehall.public_protocol)
  end

  view_test "index generates an atom feed for the current filter" do
    org = create(:organisation, name: "org-name")
    get :index, params: { departments: [org.to_param], locale: 'fr' }, format: :atom

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
    news_article = create(:published_news_article, translated_into: [:fr])
    path = Whitehall.url_maker.public_document_path(news_article, locale: :fr)

    get :index, params: { locale: 'fr' }

    assert_select "#news_article_#{news_article.id}" do
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
        path,
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
        'fr-news-title',
        options['dimension29'],
        "Expected the custom dimension 29 to have the title of the article"
      )
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
