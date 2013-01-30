require "test_helper"

class WorldLocationsControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper
  include FilterRoutesHelper

  should_be_a_public_facing_controller
  should_show_published_documents_associated_with :world_location, :policies
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
      assert_select_atom_entries([pol, pub])
    end
  end

  test "show generates an atom feed with summary content and prefixed title entries for latest activity when requested" do
    world_location = create(:world_location)
    pub = create(:published_publication, world_locations: [world_location], publication_date: 1.week.ago.to_date)
    pol = create(:published_policy, world_locations: [world_location], first_published_at: 1.day.ago)

    get :show, id: world_location, format: :atom, govdelivery_version: 'on'

    assert_select_atom_feed do
      assert_select_atom_entries([pol, pub], :summary)
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

  test "should display world_location's latest two announcements in reverse chronological order" do
    world_location = create(:world_location)
    announcement_2 = create(:published_news_article, world_locations: [world_location], first_published_at: 2.days.ago)
    announcement_3 = create(:published_speech, world_locations: [world_location], delivered_on: 3.days.ago)
    announcement_1 = create(:published_news_article, world_locations: [world_location], first_published_at: 1.day.ago)

    get :show, id: world_location

    assert_equal [announcement_1, announcement_2], assigns[:announcements]
  end

  test "should display 2 announcements with details and a link to announcements filter if there are many announcements" do
    world_location = create(:world_location)
    announcement_2 = create(:published_news_article, world_locations: [world_location], first_published_at: 2.days.ago)
    announcement_3 = create(:published_speech, world_locations: [world_location], delivered_on: 3.days.ago)
    announcement_1 = create(:published_news_article, world_locations: [world_location], first_published_at: 1.day.ago)

    get :show, id: world_location

    assert_select "#announcements" do
      assert_select_object announcement_1 do
        assert_select '.first-published-at abbr[title=?]', 1.days.ago.iso8601
        assert_select '.announcement-type', "Press release"
      end
      assert_select_object announcement_2
      refute_select_object announcement_3
      assert_select "a[href='#{announcements_filter_path(world_location)}']"
    end
  end

  test "should display world_location's latest two non-statistics publications in reverse chronological order" do
    world_location = create(:world_location)
    publication_2 = create(:published_publication, world_locations: [world_location], publication_date: 2.days.ago)
    publication_3 = create(:published_publication, world_locations: [world_location], publication_date: 3.days.ago)
    publication_1 = create(:published_publication, world_locations: [world_location], publication_date: 1.day.ago)

    statistics_publication = create(:published_publication, world_locations: [world_location], publication_date: 1.day.ago, publication_type: PublicationType::Statistics)

    get :show, id: world_location

    assert_equal [publication_1, publication_2], assigns[:non_statistics_publications]
  end

  test "should display 2 non-statistics publications with details and a link to publications filter if there are many publications" do
    world_location = create(:world_location)
    publication_2 = create(:published_publication, world_locations: [world_location], publication_date: 2.days.ago.to_date, publication_type: PublicationType::PolicyPaper)
    publication_3 = create(:published_publication, world_locations: [world_location], publication_date: 3.days.ago.to_date, publication_type: PublicationType::PolicyPaper)
    publication_1 = create(:published_publication, world_locations: [world_location], publication_date: 1.day.ago.to_date, publication_type: PublicationType::Statistics)

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
    publication_2 = create(:published_publication, world_locations: [world_location], publication_date: 2.days.ago, publication_type: PublicationType::Statistics)
    publication_3 = create(:published_publication, world_locations: [world_location], publication_date: 3.days.ago, publication_type: PublicationType::Statistics)
    publication_1 = create(:published_publication, world_locations: [world_location], publication_date: 1.day.ago, publication_type: PublicationType::NationalStatistics)
    get :show, id: world_location
    assert_equal [publication_1, publication_2], assigns[:statistics_publications]
  end

  test "should display 2 statistics publications with details and a link to publications filter if there are many publications" do
    world_location = create(:world_location)
    publication_2 = create(:published_publication, world_locations: [world_location], publication_date: 2.days.ago.to_date, publication_type: PublicationType::Statistics)
    publication_3 = create(:published_publication, world_locations: [world_location], publication_date: 3.days.ago.to_date, publication_type: PublicationType::Statistics)
    publication_1 = create(:published_publication, world_locations: [world_location], publication_date: 1.day.ago.to_date, publication_type: PublicationType::NationalStatistics)

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

end
