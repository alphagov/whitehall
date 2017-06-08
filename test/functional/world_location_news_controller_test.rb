require "test_helper"

class WorldLocationNewsControllerTest < ActionController::TestCase
  include FilterRoutesHelper
  include FeedHelper

  should_be_a_public_facing_controller

  def assert_featured_editions(editions)
    assert_equal editions, assigns(:feature_list).current_featured.map(&:edition)
  end

  setup do
    @world_location = create(:world_location, title: "UK and India", slug: "india")
  end

  view_test "index displays world location title" do
    get :index, world_location_id: @world_location
    assert_select "p.type", text: "World location news"
    assert_select "h1", text: "UK and India"
  end

  test "index responds with not found if appropriate translation doesn't exist" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :index, world_location_id: @world_location, locale: 'fr'
    end
  end

  test "index when asked for json should redirect to the api controller" do
    get :index, world_location_id: @world_location, format: :json
    assert_redirected_to api_world_location_path(@world_location, format: :json)
  end

  view_test 'index has atom feed autodiscovery link' do
    get :index, world_location_id: @world_location

    assert_select_autodiscovery_link atom_feed_url_for(@world_location)
  end

  view_test 'index includes a link to the atom feed' do
    get :index, world_location_id: @world_location

    assert_select "a.feed[href=?]", atom_feed_url_for(@world_location)
  end

  view_test "index generates an atom feed with entries for latest activity" do
    pub = create(:published_publication, world_locations: [@world_location], first_published_at: 1.week.ago.to_date)
    news = create(:published_news_article, world_locations: [@world_location], first_published_at: 1.day.ago)

    get :index, world_location_id: @world_location, format: :atom

    assert_select_atom_feed do
      assert_select_atom_entries([news, pub])
    end
  end

  test "shows the latest published edition for a featured document" do
    news = create(:published_news_article, first_published_at: 2.days.ago)
    editor = create(:departmental_editor)
    news.create_draft(editor)

    feature_list = create(:feature_list, featurable: @world_location, locale: :en)
    create(:feature, feature_list: feature_list, document: news.document)

    get :index, world_location_id: @world_location

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

    get :index, world_location_id: world_location, locale: :fr
    assert_featured_editions [less_recent_news_article, more_recent_news_article]

    get :index, world_location_id: world_location, locale: :en
    assert_featured_editions [less_recent_news_article]
  end

  test "excludes ended features" do
    news = create(:published_news_article, first_published_at: 2.days.ago)
    feature_list = create(:feature_list, featurable: @world_location, locale: :en)
    create(:feature, feature_list: feature_list, document: news.document, started_at: 2.days.ago, ended_at: 1.day.ago)

    get :index, world_location_id: @world_location
    assert_featured_editions []
  end

  test "shows a maximum of 5 featured news articles" do
    english = FeatureList.create!(featurable: @world_location, locale: :en)
    6.times do
      news_article = create(:published_news_article)
      create(:feature, feature_list: english, document: news_article.document)
    end

    get :index, world_location_id: @world_location

    assert_equal 5, assigns(:feature_list).current_feature_count
  end

  test "show should set world location slimmer headers" do
    get :index, world_location_id: @world_location.id

    assert_equal "<#{@world_location.analytics_identifier}>", response.headers["X-Slimmer-World-Locations"]
  end

  view_test "restricts atom feed entries to those with the current locale" do
    world_location = create(:world_location, translated_into: [:fr])

    translated_edition = create(:published_publication, world_locations: [world_location], translated_into: [:fr])
    create(:published_publication, world_locations: [world_location])

    get :index, world_location_id: world_location.id, format: :atom, locale: 'fr'

    assert_select_atom_feed do
      with_locale :fr do
        assert_select_atom_entries([translated_edition])
      end
    end
  end

  view_test "should show featured links if there are some" do
    featured_link = create(:featured_link, linkable: @world_location)

    get :index, world_location_id: @world_location

    assert_select '.featured-links' do
      assert_select "a[href='#{featured_link.url}']", text: featured_link.title
    end
  end
end
