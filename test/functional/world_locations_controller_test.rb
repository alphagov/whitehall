#encoding: utf-8

require "test_helper"

class WorldLocationsControllerTest < ActionController::TestCase
  include FilterRoutesHelper
  include FeedHelper

  should_be_a_public_facing_controller

  def setup
    WorldLocationNewsPageWorker.any_instance.stubs(:perform).returns(true)
  end

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

  test "should return a 404 for any world location that isn't an international delegation" do
    world_location = create(:world_location,
      title: "UK in country-name",
      world_location_type: WorldLocationType::WorldLocation,
      mission_statement: "country-mission-statement")
    assert_raise ActiveRecord::RecordNotFound do
      get :show, params: { id: world_location }
    end
  end

  view_test "should display world location title and mission statement" do
    world_location = create(
      :world_location,
      title: "UK mission to the organisation",
      world_location_type: WorldLocationType::InternationalDelegation,
      mission_statement: "delegation-mission-statement"
    )
    get :show, params: { id: world_location }
    assert_select "h1", text: "UK mission to the organisation"
    assert_select ".mission_statement", text: "delegation-mission-statement"
  end

  view_test "should use govspeak when displaying the mission statement" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation,
      mission_statement: "Line 1\n\nLine 2"
    )
    get :show, params: { id: world_location }
    assert_select ".mission_statement p", /Line 1/
    assert_select ".mission_statement p", /Line 2/
    assert_select ".mission_statement p", count: 2
  end

  test "show responds with not found if appropriate translation doesn't exist" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, params: { id: world_location, locale: 'fr' }
    end
  end

  test "show when asked for json should redirect to the api controller" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    get :show, params: { id: world_location }, format: :json
    assert_redirected_to api_world_location_path(world_location, format: :json)
  end

  view_test 'show has atom feed autodiscovery link' do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    get :show, params: { id: world_location }
    assert_select_autodiscovery_link atom_feed_url_for(world_location)
  end

  view_test 'show includes a link to the atom feed' do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    get :show, params: { id: world_location }
    assert_select "a.feed[href=?]", atom_feed_url_for(world_location)
  end

  view_test "show world location generates an atom feed with entries for latest activity" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::WorldLocation
    )
    pub = create(:published_publication, world_locations: [world_location], first_published_at: 1.week.ago.to_date)
    news = create(:published_news_article, world_locations: [world_location], first_published_at: 1.day.ago)
    get :show, params: { id: world_location }, format: :atom
    assert_select_atom_feed do
      assert_select_atom_entries([news, pub])
    end
  end

  view_test "show international delegation generates an atom feed with entries for latest activity" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    pub = create(:published_publication, world_locations: [world_location], first_published_at: 1.week.ago.to_date)
    news = create(:published_news_article, world_locations: [world_location], first_published_at: 1.day.ago)
    get :show, params: { id: world_location }, format: :atom
    assert_select_atom_feed do
      assert_select_atom_entries([news, pub])
    end
  end

  test "shows the latest published edition for a featured document" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    news = create(:published_news_article, first_published_at: 2.days.ago)
    editor = create(:departmental_editor)
    _draft = news.create_draft(editor)
    feature_list = create(:feature_list, featurable: world_location, locale: :en)
    create(:feature, feature_list: feature_list, document: news.document)
    get :show, params: { id: world_location }
    assert_featured_editions [news]
  end

  test "shows featured items in defined order for locale" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    LocalisedModel.new(world_location, :fr).update_attributes(name: "Territoire antarctique britannique")

    less_recent_news_article = create(:published_news_article, first_published_at: 2.days.ago)
    more_recent_news_article = create(:published_publication, first_published_at: 1.day.ago)
    english = FeatureList.create!(featurable: world_location, locale: :en)
    create(:feature, feature_list: english, ordering: 1, document: less_recent_news_article.document)

    french = FeatureList.create!(featurable: world_location, locale: :fr)
    create(:feature, feature_list: french, ordering: 1, document: less_recent_news_article.document)
    create(:feature, feature_list: french, ordering: 2, document: more_recent_news_article.document)

    get :show, params: { id: world_location, locale: :fr }
    assert_featured_editions [less_recent_news_article, more_recent_news_article]

    get :show, params: { id: world_location, locale: :en }
    assert_featured_editions [less_recent_news_article]
  end

  test "excludes ended features" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    news = create(:published_news_article, first_published_at: 2.days.ago)
    feature_list = create(:feature_list, featurable: world_location, locale: :en)
    create(:feature, feature_list: feature_list, document: news.document, started_at: 2.days.ago, ended_at: 1.day.ago)
    get :show, params: { id: world_location }
    assert_featured_editions []
  end

  test "shows a maximum of 5 featured news articles" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    english = FeatureList.create!(featurable: world_location, locale: :en)
    6.times do
      news_article = create(:published_news_article)
      create(:feature, feature_list: english, document: news_article.document)
    end
    get :show, params: { id: world_location }
    assert_equal 5, assigns(:feature_list).current_feature_count
  end

  test "show should set world location slimmer headers" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    get :show, params: { id: world_location.id }
    assert_equal "<#{world_location.analytics_identifier}>", response.headers["X-Slimmer-World-Locations"]
  end

  test "show should set organisations slimmer headers" do
    world_location = create(
      :world_location,
      :with_worldwide_organisations,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    get :show, params: { id: world_location.id }
    related_organisations = world_location.worldwide_organisations_with_sponsoring_organisations
    assert_equal "<#{related_organisations.map(&:analytics_identifier).join('><')}>", response.headers["X-Slimmer-Organisations"]
  end

  test "GET :show does not set empty slimmer header for locations without an org" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    get :show, params: { id: world_location.id }
    assert_nil response.headers["X-Slimmer-Organisations"]
  end

  test "should display world_location's latest two announcements in reverse chronological order" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    announcement_2 = create(:published_news_article, world_locations: [world_location], first_published_at: 2.days.ago)
    _announcement_3 = create(:published_speech, world_locations: [world_location], first_published_at: 3.days.ago)
    announcement_1 = create(:published_news_article, world_locations: [world_location], first_published_at: 1.day.ago)
    get :show, params: { id: world_location }
    assert_equal [announcement_1, announcement_2], assigns[:announcements].object
  end

  view_test "should display 2 announcements with details and a link to announcements filter if there are many announcements" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    announcement_2 = create(:published_news_article, world_locations: [world_location], first_published_at: 2.days.ago)
    announcement_3 = create(:published_speech, world_locations: [world_location], first_published_at: 3.days.ago)
    announcement_1 = create(:published_news_article, world_locations: [world_location], first_published_at: 1.day.ago)
    get :show, params: { id: world_location }
    assert_select "#announcements" do
      assert_select_object announcement_1 do
        assert_select '.publication-date time[datetime=?]', 1.days.ago.iso8601
        assert_select '.document-type', "Press release"
      end
      assert_select_object announcement_2
      refute_select_object announcement_3
      # There may be other args and we can't guarantee the order,
      # so just specify the bits we care about
      assert_select "a[href^='#{announcements_path}'][href*='world_locations%5B%5D=#{world_location.to_param}']"
    end
  end

  test "should display world_location's latest two non-statistics publications in reverse chronological order" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    publication_2 = create(:published_publication, world_locations: [world_location], first_published_at: 2.days.ago)
    _publication_3 = create(:published_publication, world_locations: [world_location], first_published_at: 3.days.ago)
    publication_1 = create(:published_publication, world_locations: [world_location], first_published_at: 1.day.ago)
    _statistics_publication = create(:published_statistics, world_locations: [world_location], first_published_at: 1.day.ago)
    get :show, params: { id: world_location }
    assert_equal [publication_1, publication_2], assigns[:non_statistics_publications].object
  end

  view_test "should display 2 non-statistics publications with details and a link to publications filter if there are many publications" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    publication_2 = create(:published_policy_paper, world_locations: [world_location], first_published_at: 2.days.ago.to_date)
    publication_3 = create(:published_policy_paper, world_locations: [world_location], first_published_at: 3.days.ago.to_date)
    publication_1 = create(:published_statistics, world_locations: [world_location], first_published_at: 1.day.ago.to_date)
    get :show, params: { id: world_location }
    assert_select "#publications" do
      assert_select_object publication_2 do
        assert_select '.publication-date time[datetime=?]', 2.days.ago.to_date.to_datetime.iso8601
        assert_select '.document-type', "Policy paper"
      end
      assert_select_object publication_3
      refute_select_object publication_1
      assert_select "a[href='#{publications_filter_path(world_location)}']"
    end
  end

  test "should display world location's latest two statistics publications in reverse chronological order" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    publication_2 = create(:published_statistics, world_locations: [world_location], first_published_at: 2.days.ago)
    _publication_3 = create(:published_statistics, world_locations: [world_location], first_published_at: 3.days.ago)
    publication_1 = create(:published_national_statistics, world_locations: [world_location], first_published_at: 1.day.ago)
    get :show, params: { id: world_location }
    assert_equal [publication_1, publication_2], assigns[:statistics_publications].object
  end

  view_test "should display 2 statistics publications with details and a link to publications filter if there are many publications" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    publication_2 = create(:published_statistics, world_locations: [world_location], first_published_at: 2.days.ago.to_date)
    publication_3 = create(:published_statistics, world_locations: [world_location], first_published_at: 3.days.ago.to_date)
    publication_1 = create(:published_national_statistics, world_locations: [world_location], first_published_at: 1.day.ago.to_date)
    get :show, params: { id: world_location }
    assert_select "#statistics-publications" do
      assert_select_object publication_1 do
        assert_select '.publication-date time[datetime=?]', 1.days.ago.to_date.to_datetime.iso8601
        assert_select '.document-type', "National Statistics"
      end
      assert_select_object publication_2
      refute_select_object publication_3
      assert_select "a[href=?]", publications_filter_path(world_location, publication_filter_option: 'statistics')
    end
  end

  view_test "should display translated page labels when requested in a different locale" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation,
      translated_into: [:fr]
    )
    create(:published_publication, world_locations: [world_location], translated_into: [:fr])
    create(:published_news_article, world_locations: [world_location], translated_into: [:fr])
    get :show, params: { id: world_location, locale: 'fr' }
    assert_select ".type", "Délégation internationale"
    assert_select "#publications .see-all a", /Voir toutes nos publications/
  end

  test "should only display translated announcements when requested for a locale" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation,
      translated_into: [:fr]
    )
    translated_speech = create(:published_speech, world_locations: [world_location], translated_into: [:fr])
    _untranslated_speech = create(:published_speech, world_locations: [world_location])
    get :show, params: { id: world_location, locale: 'fr' }
    assert_equal [translated_speech], assigns(:announcements).object
  end

  test "should only display translated publications when requested for a locale" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation,
      translated_into: [:fr]
    )
    translated_publication = create(:published_publication, world_locations: [world_location], translated_into: [:fr])
    _untranslated_publication = create(:published_publication, world_locations: [world_location])
    get :show, params: { id: world_location, locale: 'fr' }
    assert_equal [translated_publication], assigns(:non_statistics_publications).object
  end

  test "should only display translated statistics when requested for a locale" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation,
      translated_into: [:fr]
    )
    translated_statistics = create(:published_statistics, world_locations: [world_location], translated_into: [:fr])
    _untranslated_statistics = create(:published_statistics, world_locations: [world_location])
    get :show, params: { id: world_location, locale: 'fr' }
    assert_equal [translated_statistics], assigns(:statistics_publications).object
  end

  test "should only display translated recently updated editions when requested for a locale" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation,
      translated_into: [:fr]
    )
    translated_publication = create(:published_publication, world_locations: [world_location], translated_into: [:fr])
    _untranslated_publication = create(:published_publication, world_locations: [world_location])
    get :show, params: { id: world_location, locale: 'fr' }
    assert_equal [translated_publication], assigns(:recently_updated)
  end

  view_test "restricts atom feed entries to those with the current locale" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation,
      translated_into: [:fr]
    )
    translated_edition = create(:published_publication, world_locations: [world_location], translated_into: [:fr])
    _untranslated_edition = create(:published_publication, world_locations: [world_location])
    get :show, params: { id: world_location, locale: 'fr' }, format: :atom
    assert_select_atom_feed do
      with_locale :fr do
        assert_select_atom_entries([translated_edition])
      end
    end
  end

  view_test "should show featured links if there are some" do
    world_location = create(
      :world_location,
      world_location_type: WorldLocationType::InternationalDelegation
    )
    featured_link = create(:featured_link, linkable: world_location)
    get :show, params: { id: world_location }
    assert_select '.featured-links' do
      assert_select "a[href='#{featured_link.url}']", text: featured_link.title
    end
  end
end
