require "test_helper"

class CountriesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_show_published_documents_associated_with :country, :news_articles, :first_published_at
  should_show_published_documents_associated_with :country, :policies
  should_show_published_documents_associated_with :country, :speeches, :first_published_at
  should_show_published_documents_associated_with :country, :publications
  should_show_published_documents_associated_with :country, :international_priorities

  test "index should display a list of countries" do
    bat = create(:country, name: "British Antarctic Territory")
    png = create(:country, name: "Papua New Guinea")

    get :index

    assert_select ".countries" do
      assert_select_object bat
      assert_select_object png
    end
  end

  test "should display country name and description" do
    country = create(:country,
      name: "country-name",
      description: "country-description"
    )
    get :show, id: country
    assert_select ".country .name", text: "country-name"
    assert_select ".description", text: "country-description"
  end

  test "should use html line breaks when displaying the description" do
    country = create(:country, description: "Line 1\nLine 2")
    get :show, id: country
    assert_select ".description", /Line 1/
    assert_select ".description", /Line 2/
    assert_select ".description br", count: 1
  end

  test "should display a link to the about page for the country" do
    country = create(:country)
    get :show, id: country
    assert_select ".about a[href='#{about_country_path(country)}']"
  end

  test "should display an about page for the country" do
    country = create(:country,
      name: "country-name",
      about: "country-about"
    )

    get :about, id: country

    assert_select ".page_title", text: "country-name"
    assert_select ".body", text: "country-about"
  end

  test "should render the about content using govspeak markup" do
    country = create(:country,
      name: "country-name",
      about: "body-in-govspeak"
    )

    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :about, id: country
    end

    assert_select ".body", text: "body-in-html"
  end

  test "shows featured news articles in order of first publication date with most recent first" do
    country = create(:country)
    less_recent_news_article = create(:published_news_article, first_published_at: 2.days.ago)
    more_recent_news_article = create(:published_news_article, first_published_at: 1.day.ago)
    create(:edition_country, edition: less_recent_news_article, country: country, featured: true)
    create(:edition_country, edition: more_recent_news_article, country: country, featured: true)

    get :show, id: country

    assert_equal [more_recent_news_article, less_recent_news_article], assigns(:featured_news_articles)
  end

  test "shows a maximum of 3 featured news articles" do
    country = create(:country)
    4.times do
      news_article = create(:published_news_article)
      create(:edition_country, edition: news_article, country: country, featured: true)
    end

    get :show, id: country

    assert_equal 3, assigns(:featured_news_articles).length
  end

  test "shows country's featured news article with image" do
    lead_image = create(:image, alt_text: "alt-text")
    news_article = create(:published_news_article, images: [lead_image])
    country = create(:country)
    create(:edition_country, edition: news_article, country: country, featured: true)

    get :show, id: country

    assert_select_object news_article do
      assert_select ".img img[src$='#{lead_image.url}'][alt=?]", "alt-text"
    end
  end

  test "shows country's featured news article with a blank image where no image has been supplied" do
    news_article = create(:published_news_article)
    country = create(:country)
    create(:edition_country, edition: news_article, country: country, featured: true)

    get :show, id: country

    assert_select_object news_article do
      assert_select ".img img[src$='generic_image.jpg']"
    end
  end
end
