#encoding: utf-8
require "test_helper"

class WorldLocationsControllerTest < ActionController::TestCase
  include FilterRoutesHelper
  include FeedHelper

  should_be_a_public_facing_controller
  should_show_published_documents_associated_with :world_location, :policies
  should_show_published_documents_associated_with :world_location, :worldwide_priorities

  def assert_featured_editions(editions)
    assert_equal editions, assigns(:feature_list).current_featured.map(&:edition)
  end

  view_test "index should display a list of world locations" do
    bat = create(:world_location, name: "British Antarctic Territory")
    png = create(:world_location, name: "Papua New Guinea")

    get :index

    assert_select ".world-locations" do
      assert_select_object bat
      assert_select_object png
    end
  end

  test "index when asked for json should redirect to the api controller" do
    get :index, format: :json
    assert_redirected_to api_world_locations_path(format: :json)
  end

  view_test "should display world location title and mission-statement" do
    world_location = create(:world_location,
      title: "UK in country-name",
      mission_statement: "country-mission-statement"
    )
    get :show, id: world_location
    assert_select "h1", text: "UK in country-name"
    assert_select ".mission_statement", text: "country-mission-statement"
  end

  view_test "should use html line breaks when displaying the mission_statement" do
    world_location = create(:world_location, mission_statement: "Line 1\nLine 2")
    get :show, id: world_location
    assert_select ".mission_statement", /Line 1/
    assert_select ".mission_statement", /Line 2/
    assert_select ".mission_statement br", count: 1
  end

  test "show responds with not found if appropriate translation doesn't exist" do
    world_location = create(:world_location)
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, id: world_location, locale: 'fr'
    end
  end

  test "show when asked for json should redirect to the api controller" do
    world_location = create(:world_location)
    get :show, id: world_location, format: :json
    assert_redirected_to api_world_location_path(world_location, format: :json)
  end

  view_test 'show has atom feed autodiscovery link' do
    world_location = create(:world_location)

    get :show, id: world_location

    assert_select_autodiscovery_link atom_feed_url_for(world_location)
  end

  view_test 'show includes a link to the atom feed' do
    world_location = create(:world_location)

    get :show, id: world_location

    assert_select "a.feed[href=?]", atom_feed_url_for(world_location)
  end

  view_test "show generates an atom feed with entries for latest activity" do
    world_location = create(:world_location)
    pub = create(:published_publication, world_locations: [world_location], first_published_at: 1.week.ago.to_date)
    pol = create(:published_policy, world_locations: [world_location], first_published_at: 1.day.ago)

    get :show, id: world_location, format: :atom

    assert_select_atom_feed do
      assert_select_atom_entries([pol, pub])
    end
  end

  test "shows the latest published edition for a featured document" do
    world_location = create(:world_location)

    news = create(:published_news_article, first_published_at: 2.days.ago)
    editor = create(:departmental_editor)
    draft = news.create_draft(editor)

    feature_list = create(:feature_list, featurable: world_location, locale: :en)
    create(:feature, feature_list: feature_list, document: news.document)

    get :show, id: world_location

    assert_featured_editions [news]
  end

  test "shows featured items in defined order for locale" do
    world_location = create(:world_location)
    LocalisedModel.new(world_location, :fr).update_attributes(name: "Territoire antarctique britannique")

    less_recent_news_article = create(:published_news_article, first_published_at: 2.days.ago)
    more_recent_news_article = create(:published_publication, first_published_at: 1.day.ago)
    english = FeatureList.create!(featurable: world_location, locale: :en)
    create(:feature, feature_list: english, ordering: 1, document: less_recent_news_article.document)

    french = FeatureList.create!(featurable: world_location, locale: :fr)
    create(:feature, feature_list: french, ordering: 1, document: less_recent_news_article.document)
    create(:feature, feature_list: french, ordering: 2, document: more_recent_news_article.document)

    get :show, id: world_location, locale: :fr
    assert_featured_editions [less_recent_news_article, more_recent_news_article]

    get :show, id: world_location, locale: :en
    assert_featured_editions [less_recent_news_article]
  end

  test "excludes ended features" do
    world_location = create(:world_location)

    news = create(:published_news_article, first_published_at: 2.days.ago)
    feature_list = create(:feature_list, featurable: world_location, locale: :en)
    create(:feature, feature_list: feature_list, document: news.document, started_at: 2.days.ago, ended_at: 1.day.ago)

    get :show, id: world_location
    assert_featured_editions []
  end

  test "shows a maximum of 5 featured news articles" do
    world_location = create(:world_location)
    english = FeatureList.create!(featurable: world_location, locale: :en)
    6.times do
      news_article = create(:published_news_article)
      create(:feature, feature_list: english, document: news_article.document)
    end

    get :show, id: world_location

    assert_equal 5, assigns(:feature_list).current_feature_count
  end

  test "show should set slimmer analytics headers" do
    world_location = create(:world_location)

    get :show, id: world_location.id

    assert_equal "<#{world_location.analytics_identifier}>", response.headers["X-Slimmer-World-Locations"]
  end

  test "should display world_location's latest two announcements in reverse chronological order" do
    world_location = create(:world_location)
    announcement_2 = create(:published_news_article, world_locations: [world_location], first_published_at: 2.days.ago)
    announcement_3 = create(:published_speech, world_locations: [world_location], first_published_at: 3.days.ago)
    announcement_1 = create(:published_news_article, world_locations: [world_location], first_published_at: 1.day.ago)

    get :show, id: world_location

    assert_equal [announcement_1, announcement_2], assigns[:announcements].object
  end

  view_test "should display 2 announcements with details and a link to announcements filter if there are many announcements" do
    world_location = create(:world_location)
    announcement_2 = create(:published_news_article, world_locations: [world_location], first_published_at: 2.days.ago)
    announcement_3 = create(:published_speech, world_locations: [world_location], first_published_at: 3.days.ago)
    announcement_1 = create(:published_news_article, world_locations: [world_location], first_published_at: 1.day.ago)

    get :show, id: world_location

    assert_select "#announcements" do
      assert_select_object announcement_1 do
        assert_select '.publication-date abbr[title=?]', 1.days.ago.iso8601
        assert_select '.document-type', "Press release"
      end
      assert_select_object announcement_2
      refute_select_object announcement_3
      # there mey be other args and we can't guarantee the order
      # so just specifiy the bits we care about
      assert_select "a[href^='#{announcements_path}'][href*='world_locations%5B%5D=#{world_location.to_param}']"
    end
  end

  test "should display world_location's latest two non-statistics publications in reverse chronological order" do
    world_location = create(:world_location)
    publication_2 = create(:published_publication, world_locations: [world_location], first_published_at: 2.days.ago)
    publication_3 = create(:published_publication, world_locations: [world_location], first_published_at: 3.days.ago)
    publication_1 = create(:published_publication, world_locations: [world_location], first_published_at: 1.day.ago)

    statistics_publication = create(:published_statistics, world_locations: [world_location], first_published_at: 1.day.ago)

    get :show, id: world_location

    assert_equal [publication_1, publication_2], assigns[:non_statistics_publications].object
  end

  view_test "should display 2 non-statistics publications with details and a link to publications filter if there are many publications" do
    world_location = create(:world_location)
    publication_2 = create(:published_policy_paper, world_locations: [world_location], first_published_at: 2.days.ago.to_date)
    publication_3 = create(:published_policy_paper, world_locations: [world_location], first_published_at: 3.days.ago.to_date)
    publication_1 = create(:published_statistics, world_locations: [world_location], first_published_at: 1.day.ago.to_date)

    get :show, id: world_location

    assert_select "#publications" do
      assert_select_object publication_2 do
        assert_select '.publication-date abbr[title=?]', 2.days.ago.to_date.to_datetime.iso8601
        assert_select '.document-type', "Policy paper"
      end
      assert_select_object publication_3
      refute_select_object publication_1
      assert_select "a[href='#{publications_filter_path(world_location)}']"
    end
  end

  test "should display world location's latest two statistics publications in reverse chronological order" do
    world_location = create(:world_location)
    publication_2 = create(:published_statistics, world_locations: [world_location], first_published_at: 2.days.ago)
    publication_3 = create(:published_statistics, world_locations: [world_location], first_published_at: 3.days.ago)
    publication_1 = create(:published_national_statistics, world_locations: [world_location], first_published_at: 1.day.ago)
    get :show, id: world_location
    assert_equal [publication_1, publication_2], assigns[:statistics_publications].object
  end

  view_test "should display 2 statistics publications with details and a link to publications filter if there are many publications" do
    world_location = create(:world_location)
    publication_2 = create(:published_statistics, world_locations: [world_location], first_published_at: 2.days.ago.to_date)
    publication_3 = create(:published_statistics, world_locations: [world_location], first_published_at: 3.days.ago.to_date)
    publication_1 = create(:published_national_statistics, world_locations: [world_location], first_published_at: 1.day.ago.to_date)

    get :show, id: world_location

    assert_select "#statistics-publications" do
      assert_select_object publication_1 do
        assert_select '.publication-date abbr[title=?]', 1.days.ago.to_date.to_datetime.iso8601
        assert_select '.document-type', "Statistics - national statistics"
      end
      assert_select_object publication_2
      refute_select_object publication_3
      assert_select "a[href='#{publications_filter_path(world_location, publication_filter_option: 'statistics').gsub('&', '&amp;')}']"
    end
  end

  view_test "should display translated page labels when requested in a different locale" do
    world_location = create(:world_location, translated_into: [:fr])

    create(:published_worldwide_priority, world_locations: [world_location], translated_into: [:fr])
    create(:published_publication, world_locations: [world_location], translated_into: [:fr])
    create(:published_policy, world_locations: [world_location], translated_into: [:fr])

    get :show, id: world_location, locale: 'fr'

    assert_select ".type", "Localisation"
    assert_select "#worldwide-priorities", /Priorités/
    assert_select "#policies .see-all a", /Voir toutes nos priorités politiques/
    assert_select "#publications .see-all a", /Voir toutes nos publications/
  end

  test "should only display translated priorities when requested for a locale" do
    world_location = create(:world_location, translated_into: [:fr])

    translated_priority = create(:published_worldwide_priority, world_locations: [world_location], translated_into: [:fr])
    untranslated_priority = create(:published_worldwide_priority, world_locations: [world_location])

    get :show, id: world_location, locale: 'fr'

    assert_equal [translated_priority], assigns(:worldwide_priorities).object
  end

  test "should only display translated announcements when requested for a locale" do
    world_location = create(:world_location, translated_into: [:fr])

    translated_speech = create(:published_speech, world_locations: [world_location], translated_into: [:fr])
    untranslated_speech = create(:published_speech, world_locations: [world_location])

    get :show, id: world_location, locale: 'fr'

    assert_equal [translated_speech], assigns(:announcements).object
  end

  test "should only display translated publications when requested for a locale" do
    world_location = create(:world_location, translated_into: [:fr])

    translated_publication = create(:published_publication, world_locations: [world_location], translated_into: [:fr])
    untranslated_publication = create(:published_publication, world_locations: [world_location])

    get :show, id: world_location, locale: 'fr'

    assert_equal [translated_publication], assigns(:non_statistics_publications).object
  end

  test "should only display translated statistics when requested for a locale" do
    world_location = create(:world_location, translated_into: [:fr])

    translated_statistics = create(:published_statistics, world_locations: [world_location], translated_into: [:fr])
    untranslated_statistics = create(:published_statistics, world_locations: [world_location])

    get :show, id: world_location, locale: 'fr'

    assert_equal [translated_statistics], assigns(:statistics_publications).object
  end

  test "should only display translated policies when requested for a locale" do
    world_location = create(:world_location, translated_into: [:fr])

    translated_policy = create(:published_policy, world_locations: [world_location], translated_into: [:fr])
    untranslated_policy = create(:published_policy, world_locations: [world_location])

    get :show, id: world_location, locale: 'fr'

    assert_equal [translated_policy], assigns(:policies).object
  end

  test "should only display translated recently updated editions when requested for a locale" do
    world_location = create(:world_location, translated_into: [:fr])

    translated_publication = create(:published_publication, world_locations: [world_location], translated_into: [:fr])
    untranslated_publication = create(:published_publication, world_locations: [world_location])

    get :show, id: world_location, locale: 'fr'

    assert_equal [translated_publication], assigns(:recently_updated)
  end

  view_test "restricts atom feed entries to those with the current locale" do
    world_location = create(:world_location, translated_into: [:fr])

    translated_edition = create(:published_publication, world_locations: [world_location], translated_into: [:fr])
    untranslated_edition = create(:published_publication, world_locations: [world_location])

    get :show, id: world_location, format: :atom, locale: 'fr'

    french_translation_of_edition = LocalisedModel.new(translated_edition, :fr)

    assert_select_atom_feed do
      assert_select_atom_entries([french_translation_of_edition])
    end
  end

  view_test "should show top task links if there are some" do
    world_location = create(:world_location)
    top_task = create(:top_task, linkable: world_location)

    get :show, id: world_location

    assert_select '.top-tasks' do
      assert_select "a[href='#{top_task.url}']", text: top_task.title
    end
  end
end
