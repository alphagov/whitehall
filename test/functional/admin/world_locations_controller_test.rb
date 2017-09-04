require "test_helper"

class Admin::WorldLocationsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    WorldLocationNewsPageWorker.any_instance.stubs(:perform).returns(true)
  end

  should_be_an_admin_controller

  test 'should return active and inactive world locations in alphabetical order' do
    active = [
      create(:world_location, name: 'zzz', active: true),
      create(:world_location, name: 'aaa', active: true)
    ]
    inactive = [
      create(:world_location, name: 'zzz', active: false),
      create(:world_location, name: 'aaa', active: false)
    ]

    get :index

    assert_equal active.sort_by(&:name), assigns(:active_world_locations)
    assert_equal inactive.sort_by(&:name), assigns(:inactive_world_locations)
  end

  view_test 'should allow modification of existing world location data' do
    world_location = create(:world_location)

    get :edit, params: { id: world_location }

    assert_template 'world_locations/edit'
    assert_select "input[name='world_location[title]']"
    assert_select "textarea[name='world_location[mission_statement]']"
  end

  test 'updating should modify the world location' do
    world_location = create(:world_location)

    put :update, params: { id: world_location, world_location: { mission_statement: 'country-mission-statement' } }

    world_location.reload
    assert_equal 'country-mission-statement', world_location.mission_statement
  end

  test 'after updating redirects to world location show page' do
    world_location = create(:world_location)

    put :update, params: { id: world_location, world_location: { mission_statement: 'country-mission-statement' } }

    assert_redirected_to [:admin, world_location]
  end

  test "updating should be able to create a new featured link" do
    world_location = create(:world_location)

    post :update, params: { id: world_location, world_location: {
      featured_links_attributes: {"0" => {
        url: "http://www.gov.uk/mainstream/something",
        title: "Something on mainstream"
      }}
    } }

    assert world_location = WorldLocation.last
    assert featured_link = world_location.featured_links.last
    assert_equal "http://www.gov.uk/mainstream/something", featured_link.url
    assert_equal "Something on mainstream", featured_link.title
  end

  test "updating should be able to destroy an existing featured link" do
    world_location = create(:world_location)
    featured_link = create(:featured_link, linkable: world_location)

    post :update, params: { id: world_location, world_location: {
      featured_links_attributes: {"0" => {
        id: featured_link.id,
        _destroy: "1"
      }}
    } }

    refute FeaturedLink.exists?(featured_link.id)
  end

  view_test "the 'View on website' link on the show page goes to the news page" do
    world_location = create(:world_location, slug: "germany")
    get :show, id: world_location
    assert_select 'a' do |links|
      view_links = links.select { |link| link.text =~ /View on website/ }
      assert_match(/\/world\/germany\/news/, view_links.first["href"])
    end
  end

  view_test "the 'View on website' link on /features goes to the English France news page" do
    world_location = create(:world_location, slug: "france", translated_into: [:fr])
    get :features, id: world_location

    assert_select 'a' do |links|
      view_links = links.select { |link| link.text =~ /View on website/ }
      assert_match(/\/world\/france\/news/, view_links.first["href"])
    end
  end

  view_test "the 'View on website' link on /features.fr goes to the French world location page" do
    world_location = create(:world_location, slug: "france", translated_into: [:fr])
    get :features, id: world_location, locale: "fr"

    assert_select 'a' do |links|
      view_links = links.select { |link| link.text =~ /View on website/ }
      assert_match(/\/world\/france\/news\.fr/, view_links.first["href"])
    end
  end
end
