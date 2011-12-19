require "test_helper"

class CountriesControllerTest < ActionController::TestCase

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
end
