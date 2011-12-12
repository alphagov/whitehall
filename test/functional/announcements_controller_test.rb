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

  test "index shows the summary for each news article" do
    news_article = create(:published_news_article, published_at: 4.days.ago, summary: 'a-simple-summary')

    get :index

    assert_select_object news_article do
      assert_select ".summary", text: "a-simple-summary"
    end
  end

  test "index shows related policy areas for each news article" do
    first_policy_area = create(:policy_area, name: 'first-area')
    second_policy_area = create(:policy_area, name: 'second-area')
    policy = create(:published_policy, policy_areas: [first_policy_area, second_policy_area])
    news_article = create(:published_news_article, published_at: 4.days.ago, related_documents: [policy])

    get :index

    assert_select_object news_article do
      assert_select "a[href='#{policy_area_path(first_policy_area)}']", text: first_policy_area.name
      assert_select "a[href='#{policy_area_path(second_policy_area)}']", text: second_policy_area.name
    end
  end

  test "should display the date the featured news article was published" do
    published_at = Time.zone.now
    news_article = create(:published_news_article, featured: true, published_at: published_at)
    get :index
    assert_select send("featured_news_articles_selector") do
      assert_select "#{record_css_selector(news_article)} .published_at[title=#{published_at.iso8601}]"
    end
  end
end