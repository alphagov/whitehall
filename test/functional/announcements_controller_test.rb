require "test_helper"
require "gds_api/test_helpers/content_store"

class AnnouncementsControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper
  include DocumentFilterHelpers
  include GdsApi::TestHelpers::ContentStore
  include TaxonomyHelper

#  should_be_a_public_facing_controller
#  should_return_json_suitable_for_the_document_filter :news_article
#  should_return_json_suitable_for_the_document_filter :speech

  setup do
    @content_item = content_item_for_base_path(
      '/government/announcements'
    )

    content_store_has_item(@content_item['base_path'], @content_item)
    stub_taxonomy_with_all_taxons
  end

  view_test "index shows a mix of news and speeches" do
    rummager = stub
    with_stubbed_rummager(rummager) do
      Sidekiq::Testing.inline! do
        rummager.expects(:search).returns({'results' =>
                                             [{'format' => 'news_article', 'content_id'=>'news_id'},
                                              {'format' => 'speech', 'content_id'=>'speech_id'}]
                                          })

        get :index

        assert_select '#news_article_news_id'
        assert_select '#speech_speech_id'
      end
    end
  end
  test "index sets Cache-Control: max-age to the time of the next scheduled publication" do
    create(:scheduled_news_article, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :index
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age / 2}")
  end

  view_test "index shows which type a record is" do
    rummager = stub
    with_stubbed_rummager(rummager) do
      Sidekiq::Testing.inline! do
        rummager.expects(:search).returns({'results' =>
                                             [{'format' => 'news_story', 'content_id'=>'news_id'},
                                              {'format' => 'speech', 'content_id'=>'speech_id'},
                                              {'format' => 'written_statement', 'content_id'=>'written_statement_id'}]
                                          })

        get :index

        assert_select '#news_story_news_id' do
          assert_select ".display-type", text: "News story"
        end
        assert_select '#speech_speech_id' do
          assert_select ".display-type", text: "Speech"
        end
        assert_select '#written_statement_written_statement_id' do
          assert_select ".display-type", text: "Statement to Parliament"
        end
      end
    end
  end
=begin

  view_test "index shows the date on which a speech was first published" do
    first_published_at = Date.parse("1999-12-31")
    Sidekiq::Testing.inline! do
      speech = create(:published_speech, first_published_at: first_published_at)

      get :index

      assert_select_object(speech) do
        assert_select "time.public_timestamp[datetime=?]", first_published_at.to_datetime.iso8601
      end
    end
  end

  view_test "index shows the time when a news article was first published" do
    first_published_at = Time.zone.parse("2001-01-01 01:01")
    Sidekiq::Testing.inline! do
      news_article = create(:published_news_article, first_published_at: first_published_at)

      get :index

      assert_select_object(news_article) do
        assert_select "time.public_timestamp[datetime=?]", first_published_at.iso8601
      end
    end
  end

  view_test "index shows related organisations for each type of article" do
    Sidekiq::Testing.inline! do
      first_org = create(:organisation, name: 'first-org', acronym: "FO")
      second_org = create(:organisation, name: 'second-org', acronym: "SO")
      news_article = create(:published_news_article, first_published_at: 4.days.ago, organisations: [first_org, second_org])
      speech = create(:published_speech, delivered_on: 5.days.ago, organisations: [second_org])

      get :index

      assert_select_object news_article do
        assert_select ".organisations", text: "#{first_org.acronym} and #{second_org.acronym}", count: 1
      end

      assert_select_object speech do
        assert_select ".organisations", text: second_org.acronym, count: 1
      end
    end
  end

  view_test "index shows articles in reverse chronological order" do
    Sidekiq::Testing.inline! do
      oldest = create(:published_speech, first_published_at: 5.days.ago)
      newest = create(:published_news_article, first_published_at: 4.days.ago)

      get :index

      assert_select "#{record_css_selector(newest)} + #{record_css_selector(oldest)}"
    end
  end

  view_test "index shows selected announcement type filter option in the title" do
    get :index, params: { announcement_filter_option: 'news-stories' }

    assert_select 'h1 span', ': news stories'
  end

  view_test "index indicates selected announcement type filter option in the filter selector" do
    get :index, params: { announcement_filter_option: 'news-stories' }

    assert_select "select[name='announcement_filter_option']" do
      assert_select "option[selected='selected']", text: Whitehall::AnnouncementFilterOption::NewsStory.label
    end
  end

  view_test "index indicates selected world location in the filter selector" do
    world_location_1 = create(:world_location, name: "Afghanistan")
    world_location_2 = create(:world_location, name: "Albania")
    world_location_3 = create(:world_location, name: "Algeria")

    create(:published_news_article, world_locations: [world_location_1, world_location_2, world_location_3])

    get :index, params: { world_locations: [world_location_1.slug, world_location_3.slug] }

    assert_select "select[name='world_locations[]']" do
      assert_select "option[selected='selected']", count: 2
    end
  end

  view_test "index indicates selected people in the filter selector" do
    a_person = create(:person, forename: "Jane", surname: "Doe")

    get :index, params: { people: [a_person.slug] }

    assert_select "select[name='people[]']" do
      assert_select "option[selected='selected']", text: "Jane Doe"
    end
  end

  def assert_documents_appear_in_order_within(containing_selector, expected_documents)
    articles = css_select "#{containing_selector} li.document-row"
    expected_document_ids = expected_documents.map { |doc| dom_id(doc) }
    actual_document_ids = articles.map { |a| a["id"] }
    assert_equal expected_document_ids, actual_document_ids
  end

  view_test "index shows only the first page of news articles or speeches" do
    Sidekiq::Testing.inline! do
      news = (1..2).map { |n| create(:published_news_article, first_published_at: n.days.ago) }
      speeches = (3..4).map { |n| create(:published_speech, first_published_at: n.days.ago) }

      with_number_of_documents_per_page(3) do
        get :index
      end

      assert_documents_appear_in_order_within(".filter-results", news + speeches[0..0])
      (speeches[1..2]).each do |speech|
        refute_select_object(speech)
      end
    end
  end

  view_test "index shows the requested page" do
    Sidekiq::Testing.inline! do
      news = (1..3).map { |n| create(:published_news_article, first_published_at: n.days.ago) }
      speeches = (4..6).map { |n| create(:published_speech, first_published_at: n.days.ago) }

      Whitehall.search_client.stubs(:search).with({}).returns {}

      with_number_of_documents_per_page(4) do
        get :index, params: { page: 2 }
      end

      assert_documents_appear_in_order_within(".filter-results", speeches[1..2])
      (news + speeches[0..0]).each do |speech|
        refute_select_object(speech)
      end
    end
  end



  view_test 'index only lists documents in the given locale' do
    english_article = create(:published_news_article)
    french_article = create(:published_news_article, translated_into: [:fr])
    get :index, params: { locale: 'fr' }

    assert_select_object french_article
    refute_select_object english_article
  end

  view_test 'index for non-english locale copes when a nil page is specified' do
    _english_article = create(:published_news_article)
    _french_article = create(:published_news_article, translated_into: [:fr])
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
    Sidekiq::Testing.inline! do
      news_article = create(:published_news_article)

      get :index

      assert_select_object(news_article) do
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
          @controller.public_document_path(news_article),
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
          news_article.title,
          options['dimension29'],
          "Expected the custom dimension 29 to have the title of the article"
        )
      end
    end
  end
=end
end
