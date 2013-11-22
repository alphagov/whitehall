require 'test_helper'

class NewsArticlesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  # should_render_a_list_of :news_articles, :first_published_at
  should_show_the_world_locations_associated_with :news_article
  should_display_inline_images_for :news_article
  should_set_meta_description_for :news_article
  should_set_slimmer_analytics_headers_for :news_article

  test "shows published news article" do
    news_article = create(:published_news_article)
    get :show, id: news_article.document
    assert_response :success
  end

  view_test "renders the news article summary from plain text" do
    news_article = create(:published_news_article, summary: 'plain text & so on')
    get :show, id: news_article.document

    assert_select ".summary", text: "plain text &amp; so on"
  end

  view_test "renders the news article body using govspeak" do
    news_article = create(:published_news_article, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: news_article.document
    end

    assert_select ".body", text: "body-in-html"
  end

  view_test "shows when updated news article was first published and last updated" do
    news_article = create(:published_news_article, first_published_at: 10.days.ago)

    editor = create(:departmental_editor)
    updated_news_article = news_article.create_draft(editor)
    updated_news_article.change_note = "change-note"
    force_publish(updated_news_article)

    get :show, id: updated_news_article.document

    assert_select ".meta" do
      assert_select ".published-at[title='#{news_article.first_published_at.iso8601}']"
      assert_select ".published-at[title='#{updated_news_article.public_timestamp.iso8601}']"
    end
  end

  test "the format name is being set to news" do
    news_article = create(:published_news_article)

    get :show, id: news_article.document

    assert_equal "news", response.headers["X-Slimmer-Format"]
  end
end
