require "test_helper"

class Admin::WorldLocationNewsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    WorldLocationNewsWorker.any_instance.stubs(:perform).returns(true)
  end

  should_be_an_admin_controller

  test "should return active and inactive world locations in alphabetical order" do
    active = [
      create(:world_location, name: "zzz", active: true),
      create(:world_location, name: "aaa", active: true),
    ]
    inactive = [
      create(:world_location, name: "zzz", active: false),
      create(:world_location, name: "aaa", active: false),
    ]

    get :index

    assert_equal active.sort_by(&:name), assigns(:active_world_locations)
    assert_equal inactive.sort_by(&:name), assigns(:inactive_world_locations)
  end

  view_test "should allow modification of existing world location data" do
    world_location = create(:world_location)

    get :edit, params: { id: world_location.world_location_news }

    assert_template "world_location_news/edit"
    assert_select "input[name='world_location_news[title]']"
    assert_select "textarea[name='world_location_news[mission_statement]']"
  end

  test "updating should modify the world location" do
    world_location = create(:world_location)

    put :update, params: { id: world_location, world_location_news: { mission_statement: "country-mission-statement" } }

    world_location.reload
    assert_equal "country-mission-statement", world_location.world_location_news.mission_statement
  end

  test "after updating redirects to world location show page" do
    world_location = create(:world_location)

    put :update, params: { id: world_location.world_location_news, world_location_news: { mission_statement: "country-mission-statement" } }

    assert_redirected_to [:admin, world_location.world_location_news]
  end

  test "updating should be able to create a new featured link" do
    world_location = create(:world_location)

    post :update,
         params: { id: world_location,
                   world_location_news: {
                     featured_links_attributes: [{
                       url: "http://www.gov.uk/mainstream/something",
                       title: "Something on mainstream",
                     }],
                     title: "Something on mainstream",
                   } }

    assert world_location = WorldLocation.last
    assert featured_link = world_location.world_location_news.featured_links.last
    assert_equal "http://www.gov.uk/mainstream/something", featured_link.url
    assert_equal "Something on mainstream", featured_link.title
  end

  test "updating should be able to destroy an existing featured link" do
    world_location = create(:world_location)
    featured_link = create(:featured_link, linkable: world_location.world_location_news)

    post :update,
         params: { id: world_location,
                   world_location_news: {
                     featured_links_attributes: [{
                       id: featured_link.id,
                       _destroy: "1",
                     }],
                   } }

    assert_not FeaturedLink.exists?(featured_link.id)
  end

  view_test "the 'View on website' link on the show page goes to the news page" do
    world_location = create(:world_location, slug: "germany")
    get :show, params: { id: world_location }
    assert_select "a" do |links|
      view_links = links.select { |link| link.text =~ /View on website/ }
      assert_match(/#{Regexp.escape("https://www.test.gov.uk/world/germany/news")}/, view_links.first["href"])
    end
  end

  view_test "the 'View on website' link on /features goes to the English France news page" do
    world_location = create(:world_location, slug: "france", translated_into: [:fr])
    get :features, params: { id: world_location }

    assert_select "a" do |links|
      view_links = links.select { |link| link.text =~ /View on website/ }
      assert_match(/#{Regexp.escape("https://www.test.gov.uk/world/france/news")}/, view_links.first["href"])
    end
  end

  view_test "the 'View on website' link on /features.fr goes to the French world location page" do
    world_location_news = build(:world_location_news, translated_into: [:fr])
    create(:world_location, slug: "france", translated_into: [:fr], world_location_news: world_location_news)
    get :features, params: { id: world_location_news, locale: "fr" }

    assert_select "a" do |links|
      view_links = links.select { |link| link.text =~ /View on website/ }
      assert_match(/#{Regexp.escape("https://www.test.gov.uk/world/france/news.fr")}/, view_links.first["href"])
    end
  end

  view_test "the featurables tab should display information regarding the maximum number of featurable documents" do
    first_feature = build(:feature, document: create(:published_case_study).document, ordering: 1)
    world_location = create(:world_location, slug: "france")
    create(:feature_list, locale: :en, featurable: world_location, features: [first_feature])
    get :features, params: { id: world_location }

    assert_match(/Please note that you can only feature a maximum of [\d+] documents.*/, response.body)
  end
end
