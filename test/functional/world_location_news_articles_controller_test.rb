require 'test_helper'

class WorldLocationNewsArticlesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_show_the_world_locations_associated_with :world_location_news_article
  should_display_inline_images_for :world_location_news_article
  should_set_meta_description_for :world_location_news_article

  test "shows published world location news article" do
    world_news_article = create(:published_world_location_news_article)
    get :show, id: world_news_article.document
    assert_response :success
  end

  test "index redirects to the announcements page with the world location news flag" do
    get :index
    assert_redirected_to announcements_path(include_world_location_news: "1")
  end

  view_test "renders the world location news article summary from plain text" do
    world_news_article = create(:published_world_location_news_article, summary: 'plain text & so on')
    get :show, id: world_news_article.document

    assert_select ".summary", text: "plain text &amp; so on"
  end

  view_test "renders the world location news article body using govspeak" do
    world_news_article = create(:published_world_location_news_article, body: "body-in-govspeak")
    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :show, id: world_news_article.document
    end

    assert_select ".body", text: "body-in-html"
  end

  view_test "shows when updated world location news article was first published and last updated" do
    world_news_article = create(:published_world_location_news_article, first_published_at: 10.days.ago)

    editor = create(:departmental_editor)
    updated_world_news_article = world_news_article.create_draft(editor)
    updated_world_news_article.change_note = "change-note"
    updated_world_news_article.publish_as(editor, force: true)

    get :show, id: updated_world_news_article.document

    assert_select ".meta" do
      assert_select ".published-at[title='#{world_news_article.first_published_at.iso8601}']"
      assert_select ".published-at[title='#{updated_world_news_article.public_timestamp.iso8601}']"
    end
  end

  test "the format name is being set to news" do
    world_news_article = create(:published_world_location_news_article)

    get :show, id: world_news_article.document

    assert_equal "news", response.headers["X-Slimmer-Format"]
  end
end
