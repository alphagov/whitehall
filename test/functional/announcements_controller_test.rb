require "test_helper"

class AnnouncementsControllerTest < ActionController::TestCase
  include DocumentControllerTestHelpers

  should_render_a_list_of :news_articles
  should_render_a_list_of :speeches
  should_show_featured_documents_for :news_article

  test "index shows when each news article was last updated" do
    news_article = create(:published_news_article, published_at: 4.days.ago)

    get :index

    assert_select_object news_article do
      assert_select ".published_at", text: "4 days ago"
    end
  end
end