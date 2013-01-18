require "test_helper"

class WorldLocationsControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper

  should_be_a_public_facing_controller
  should_show_published_documents_associated_with :world_location, :news_articles
  should_show_published_documents_associated_with :world_location, :policies
  should_show_published_documents_associated_with :world_location, :speeches, :delivered_on
  should_show_published_documents_associated_with :world_location, :publications, :publication_date
  should_show_published_documents_associated_with :world_location, :international_priorities

  test "index should display a list of world locations" do
    bat = create(:overseas_territory, name: "British Antarctic Territory")
    png = create(:country, name: "Papua New Guinea")

    get :index

    assert_select ".world-locations" do
      assert_select_object bat
      assert_select_object png
    end
  end

  test "should display world location name and description" do
    world_location = create(:world_location,
      name: "country-name",
      description: "country-description"
    )
    get :show, id: world_location
    assert_select ".name", text: "UK and country-name"
    assert_select ".description", text: "country-description"
  end

  test "should use html line breaks when displaying the description" do
    world_location = create(:world_location, description: "Line 1\nLine 2")
    get :show, id: world_location
    assert_select ".description", /Line 1/
    assert_select ".description", /Line 2/
    assert_select ".description br", count: 1
  end

  test 'show has atom feed autodiscovery link' do
    world_location = create(:world_location)

    get :show, id: world_location

    assert_select_autodiscovery_link world_location_url(world_location, format: "atom")
  end

  test 'show includes a link to the atom feed' do
    world_location = create(:world_location)

    get :show, id: world_location

    assert_select "a.feed[href=?]", world_location_url(world_location, format: :atom)
  end

  test "show generates an atom feed with entries for latest activity" do
    world_location = create(:world_location)
    pub = create(:published_publication, world_locations: [world_location], publication_date: 1.week.ago.to_date)
    pol = create(:published_policy, world_locations: [world_location], first_published_at: 1.day.ago)

    get :show, id: world_location, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > entry', count: 2 do |entries|
        entries.zip([pol, pub]).each do |entry, document|
          assert_select_atom_entry entry, document
          assert_select entry, 'entry > content[type=?]', 'html', count: 1, text: /#{document.body}/
        end
      end
    end
  end

  test "show generates an atom feed with summary content and prefixed title entries for latest activity when requested" do
    world_location = create(:world_location)
    pub = create(:published_publication, world_locations: [world_location], publication_date: 1.week.ago.to_date)
    pol = create(:published_policy, world_locations: [world_location], first_published_at: 1.day.ago)

    get :show, id: world_location, format: :atom, govdelivery_version: 'on'

    assert_select_atom_feed do
      assert_select 'feed > entry', count: 2 do |entries|
        entries.zip([pol, pub]).each do |entry, document|
          assert_select_atom_entry entry, document
          assert_select entry, 'entry > content[type=?]', 'text', count: 1, text: document.summary
        end
      end
    end
  end

  test "should display an about page for the world location" do
    world_location = create(:world_location,
      name: "country-name",
      about: "country-about"
    )

    get :about, id: world_location

    assert_select ".page_title", text: "country-name"
    assert_select ".body", text: "country-about"
  end

  test "should render the about content using govspeak markup" do
    world_location = create(:world_location,
      name: "country-name",
      about: "body-in-govspeak"
    )

    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :about, id: world_location
    end

    assert_select ".body", text: "body-in-html"
  end

  test "shows featured news articles in order of first publication date with most recent first" do
    world_location = create(:world_location)
    less_recent_news_article = create(:published_news_article, first_published_at: 2.days.ago)
    more_recent_news_article = create(:published_news_article, first_published_at: 1.day.ago)
    create(:edition_world_location, edition: less_recent_news_article, world_location: world_location, featured: true)
    create(:edition_world_location, edition: more_recent_news_article, world_location: world_location, featured: true)

    get :show, id: world_location

    assert_equal [more_recent_news_article, less_recent_news_article], assigns(:featured_news_articles)
  end

  test "shows a maximum of 3 featured news articles" do
    world_location = create(:world_location)
    4.times do
      news_article = create(:published_news_article)
      create(:edition_world_location, edition: news_article, world_location: world_location, featured: true)
    end

    get :show, id: world_location

    assert_equal 3, assigns(:featured_news_articles).length
  end
end
