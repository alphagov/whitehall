require "test_helper"

class CountriesControllerTest < ActionController::TestCase
  test "index should display a list of countries" do
    bat = create(:country, name: "British Antarctic Territory")
    png = create(:country, name: "Papua New Guinea")

    get :index

    assert_select ".countries" do
      assert_select_object bat
      assert_select_object png
    end
  end

  test "shows only published news articles associated with country" do
    published_document = create(:published_news_article)
    draft_document = create(:draft_news_article)
    another_published_document = create(:published_news_article)
    country = create(:country, documents: [published_document, draft_document])

    get :show, id: country

    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
    assert_select_object(another_published_document, count: 0)
  end

  test "should not display an empty published news articles section" do
    country = create(:country, documents: [])

    get :show, id: country

    assert_select "#news_articles", count: 0
  end
end