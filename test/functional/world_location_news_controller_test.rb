require "test_helper"

class WorldLocationNewsControllerTest < ActionController::TestCase
  include FilterRoutesHelper
  include FeedHelper

  should_be_a_public_facing_controller

  def assert_featured_editions(editions)
    assert_equal editions, assigns(:feature_list).current_featured.map(&:edition)
  end

  def default_search_options
    {
      filter_world_locations: @world_location.slug,
      order: "-public_timestamp",
      fields: %w[
        display_type
        title
        link
        public_timestamp
        format
        content_store_document_type
        description
        content_id
        organisations
        document_collections
      ],
    }
  end

  def announcement_search_options
    default_search_options.merge(
      count: 2,
      filter_content_store_document_type: announcement_document_types,
    )
  end

  def announcement_document_types
    non_world_announcement_types = Whitehall::AnnouncementFilterOption.all.map(&:document_type).flatten
    non_world_announcement_types + %w[world_news_story]
  end

  setup do
    @world_location = create(
      :world_location,
      title: "UK and India",
      slug: "india",
      mission_statement: "country-mission-statement",
    )

    @translated_world_location = create(:world_location, translated_into: [:fr])
    @rummager = stub
  end

  view_test "index displays world location title and mission-statement" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).twice.returns("results" => [])
      get :index, params: { world_location_id: @world_location }

      assert_select "title", text: "UK and India - GOV.UK"
      assert_select ".gem-c-title__context", text: "World location news"
      assert_select "h1", text: "UK and India"
      assert_select ".mission_statement", text: "country-mission-statement"
    end
  end

  test "index responds with not found if appropriate translation doesn't exist" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :index, params: { world_location_id: @world_location, locale: "fr" }
    end
  end

  test "index when asked for json should redirect to the api controller" do
    get :index, params: { world_location_id: @world_location }, format: :json
    assert_redirected_to api_world_location_path(@world_location, format: :json)
  end

  view_test "index has atom feed autodiscovery link" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).twice.returns("results" => [])
      get :index, params: { world_location_id: @world_location }

      assert_select_autodiscovery_link atom_feed_url_for(@world_location)
    end
  end

  view_test "index includes a link to the atom feed" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).twice.returns("results" => [])
      get :index, params: { world_location_id: @world_location }

      assert_select "input[name=\"feed-reader-box\"][value=?]", atom_feed_url_for(@world_location)
    end
  end

  view_test "index generates an atom feed with entries for latest activity" do
    with_stubbed_rummager(@rummager) do
      documents = [
        { "content_store_document_type" => "publication", "public_timestamp" => 1.week.ago.to_date },
        { "content_store_document_type" => "news_article", "public_timestamp" => 1.day.ago },
      ]
      @rummager.expects(:search).once.returns("results" => documents)

      get :index, params: { world_location_id: @world_location }, format: :atom

      assert_select_atom_feed do
        assert_select "feed > id", 1
        assert_select "feed > title", 1
        assert_select "feed > author, feed > entry > author"
        assert_select "feed > updated", 1
        assert_select "feed > link[rel=?][type=?][href=?]",
                      "self",
                      "application/atom+xml",
                      world_location_news_index_url(format: :atom, world_location_id: @world_location),
                      1
        assert_select "feed > link[rel=?][type=?][href=?]", "alternate", "text/html", root_url, 1
      end
    end
  end

  test "shows the latest published edition for a featured document" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).twice.returns("results" => [])
      news = create(:published_news_article, first_published_at: 2.days.ago)
      editor = create(:departmental_editor)
      news.create_draft(editor)

      feature_list = create(:feature_list, featurable: @world_location, locale: :en)
      create(:feature, feature_list: feature_list, document: news.document)

      get :index, params: { world_location_id: @world_location }

      assert_featured_editions [news]
    end
  end

  test "shows featured items in defined order for locale" do
    with_stubbed_rummager(@rummager) do
      WorldLocationNewsPageWorker.any_instance.stubs(:perform).returns(true)
      LocalisedModel.new(@world_location, :fr).update!(name: "Territoire antarctique britannique")

      less_recent_news_article = create(:published_news_article, first_published_at: 2.days.ago)
      more_recent_news_article = create(:published_publication, first_published_at: 1.day.ago)
      english = FeatureList.create!(featurable: @world_location, locale: :en)
      create(:feature, feature_list: english, ordering: 1, document: less_recent_news_article.document)

      french = FeatureList.create!(featurable: @world_location, locale: :fr)
      create(:feature, feature_list: french, ordering: 1, document: less_recent_news_article.document)
      create(:feature, feature_list: french, ordering: 2, document: more_recent_news_article.document)

      get :index, params: { world_location_id: @world_location, locale: :fr }
      assert_featured_editions [less_recent_news_article, more_recent_news_article]

      @rummager.expects(:search).returns("results" => []).twice
      get :index, params: { world_location_id: @world_location, locale: :en }
      assert_featured_editions [less_recent_news_article]
    end
  end

  test "excludes ended features" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).twice
      news = create(:published_news_article, first_published_at: 2.days.ago)
      feature_list = create(:feature_list, featurable: @world_location, locale: :en)
      create(:feature, feature_list: feature_list, document: news.document, started_at: 2.days.ago, ended_at: 1.day.ago)

      get :index, params: { world_location_id: @world_location }
      assert_featured_editions []
    end
  end

  test "shows a maximum of 5 featured news articles" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).twice
      english = FeatureList.create!(featurable: @world_location, locale: :en)
      6.times do
        news_article = create(:published_news_article)
        create(:feature, feature_list: english, document: news_article.document)
      end

      get :index, params: { world_location_id: @world_location }

      assert_equal 5, assigns(:feature_list).current_feature_count
    end
  end

  test "should set world location slimmer headers" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).twice
      get :index, params: { world_location_id: @world_location.id }

      assert_equal "<#{@world_location.analytics_identifier}>", response.headers["X-Slimmer-World-Locations"]
    end
  end

  view_test "should display 2 announcements with details and a link to announcements filter if there are many announcements" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).once
      @rummager.expects(:search).with(announcement_search_options).returns("results" => [
        { "public_timestamp" => 1.day.ago, "content_id" => "content_id_1", "content_store_document_type" => "news_story" },
        { "public_timestamp" => 2.days.ago, "content_id" => "content_id_2", "content_store_document_type" => "news_story" },
      ]).once

      get :index, params: { world_location_id: @world_location }
      assert_select "#our-announcements" do
        assert_select "#announcements_content_id_1" do
          assert_select ".publication-date time[datetime=?]", 1.day.ago.utc.iso8601
          assert_select ".document-type", "News story"
        end
        assert_select "#announcements_content_id_2" do
          assert_select ".publication-date time[datetime=?]", 2.days.ago.utc.iso8601
          assert_select ".document-type", "News story"
        end
        assert_select "a[href^='#{announcements_path}'][href*='world_locations%5B%5D=#{@world_location.to_param}']"
      end
    end
  end

  test "should display world_location's latest two non-statistics publications in reverse chronological order" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).twice

      publication2 = create(:published_publication, world_locations: [@world_location], first_published_at: 2.days.ago)
      publication1 = create(:published_publication, world_locations: [@world_location], first_published_at: 1.day.ago)
      create(:published_publication, world_locations: [@world_location], first_published_at: 3.days.ago)

      create(:published_statistics, world_locations: [@world_location], first_published_at: 1.day.ago)

      get :index, params: { world_location_id: @world_location }

      assert_equal [publication1, publication2], assigns[:non_statistics_publications].object
    end
  end

  view_test "should display 2 non-statistics publications with details and a link to publications filter if there are many publications" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).twice

      publication2 = create(:published_policy_paper, world_locations: [@world_location], first_published_at: 2.days.ago.to_date)
      publication3 = create(:published_policy_paper, world_locations: [@world_location], first_published_at: 3.days.ago.to_date)
      publication1 = create(:published_statistics, world_locations: [@world_location], first_published_at: 1.day.ago.to_date)

      get :index, params: { world_location_id: @world_location }

      assert_select "#publications" do
        assert_select_object publication2 do
          assert_select ".publication-date time[datetime=?]", 2.days.ago.midnight.iso8601
          assert_select ".document-type", "Policy paper"
        end
        assert_select_object publication3
        refute_select_object publication1
        assert_select "a[href='#{publications_filter_path(@world_location)}']"
      end
    end
  end

  test "should display world location's latest two statistics publications in reverse chronological order" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).twice

      publication2 = create(:published_statistics, world_locations: [@world_location], first_published_at: 2.days.ago)
      publication1 = create(:published_national_statistics, world_locations: [@world_location], first_published_at: 1.day.ago)
      create(:published_statistics, world_locations: [@world_location], first_published_at: 3.days.ago)

      get :index, params: { world_location_id: @world_location }
      assert_equal [publication1, publication2], assigns[:statistics_publications].object
    end
  end

  view_test "should display 2 statistics publications with details and a link to publications filter if there are many publications" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).twice

      publication2 = create(:published_statistics, world_locations: [@world_location], first_published_at: 2.days.ago.to_date)
      publication3 = create(:published_statistics, world_locations: [@world_location], first_published_at: 3.days.ago.to_date)
      publication1 = create(:published_national_statistics, world_locations: [@world_location], first_published_at: 1.day.ago.to_date)

      get :index, params: { world_location_id: @world_location }

      assert_select "#statistics-publications" do
        assert_select_object publication1 do
          assert_select ".publication-date time[datetime=?]", 1.day.ago.midnight.iso8601
          assert_select ".document-type", "National Statistics"
        end
        assert_select_object publication2
        refute_select_object publication3
        assert_select "a[href=?]", publications_filter_path(@world_location, publication_filter_option: "statistics")
      end
    end
  end

  view_test "should display translated page labels when requested in a different locale" do
    create(:published_publication, world_locations: [@translated_world_location], translated_into: [:fr])
    create(:published_news_article, world_locations: [@translated_world_location], translated_into: [:fr])

    get :index, params: { world_location_id: @translated_world_location, locale: "fr" }

    assert_select ".gem-c-title__context", "World location news"
    assert_select "#publications .see-all a", /Voir toutes nos publications/
    assert_select ".see-all a", /Voir toutes nos annonces/
  end

  test "should only display translated announcements when requested for a locale" do
    translated_speech = create(:published_speech, world_locations: [@translated_world_location], translated_into: [:fr])
    create(:published_speech, world_locations: [@translated_world_location])

    get :index, params: { world_location_id: @translated_world_location, locale: "fr" }

    assert_equal [translated_speech], assigns(:announcements).object
  end

  test "should only display translated publications when requested for a locale" do
    translated_publication = create(:published_publication, world_locations: [@translated_world_location], translated_into: [:fr])
    create(:published_publication, world_locations: [@translated_world_location])

    get :index, params: { world_location_id: @translated_world_location, locale: "fr" }

    assert_equal [translated_publication], assigns(:non_statistics_publications).object
  end

  test "should only display translated statistics when requested for a locale" do
    translated_statistics = create(:published_statistics, world_locations: [@translated_world_location], translated_into: [:fr])
    create(:published_statistics, world_locations: [@translated_world_location])

    get :index, params: { world_location_id: @translated_world_location, locale: "fr" }

    assert_equal [translated_statistics], assigns(:statistics_publications).object
  end

  test "should only display translated recently updated editions when requested for a locale" do
    translated_publication = create(:published_publication, world_locations: [@translated_world_location], translated_into: [:fr])
    create(:published_publication, world_locations: [@translated_world_location])

    get :index, params: { world_location_id: @translated_world_location, locale: "fr" }

    assert_equal [translated_publication], assigns(:recently_updated)
  end

  view_test "restricts atom feed entries to those with the current locale" do
    translated_edition = create(:published_publication, world_locations: [@translated_world_location], translated_into: [:fr])
    create(:published_publication, world_locations: [@translated_world_location])

    get :index, params: { world_location_id: @translated_world_location.id, locale: "fr" }, format: :atom

    assert_select_atom_feed do
      with_locale :fr do
        assert_select_atom_entries([translated_edition])
      end
    end
  end

  view_test "should show featured links if there are some" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).twice
      featured_link = create(:featured_link, linkable: @world_location)

      get :index, params: { world_location_id: @world_location }

      assert_select ".featured-links" do
        assert_select "a[href='#{featured_link.url}']", text: featured_link.title
      end
    end
  end

  view_test "does not set lang=en on featured links for english pages" do
    with_stubbed_rummager(@rummager) do
      @rummager.expects(:search).returns("results" => []).twice
      create(:featured_link, linkable: @world_location)

      get :index, params: { world_location_id: @world_location }

      assert_select ".featured-links[lang=en]", false, "English world location pages should not set lang=en on featured links"
    end
  end

  view_test "sets lang=en on featured links for translated pages" do
    create(:published_publication, world_locations: [@translated_world_location], translated_into: [:fr])
    create(:published_publication, world_locations: [@translated_world_location])

    get :index, params: { world_location_id: @translated_world_location, locale: "fr" }

    assert_select ".featured-links[lang=en]"
  end
end
