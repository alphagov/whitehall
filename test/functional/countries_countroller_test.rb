require "test_helper"

class CountriesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_show_published_documents_associated_with :country, :news_articles
  should_show_published_documents_associated_with :country, :policies
  should_show_published_documents_associated_with :country, :speeches
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

    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :about, id: country

    assert_select ".body", text: "body-in-html"
  end
end
