require 'test_helper'

class NewsArticlesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller
  should_render_a_list_of :news_articles
  should_show_related_policies_and_policy_areas_for :news_article
  should_show_the_countries_associated_with :news_article

  test "shows published news article" do
    news_article = create(:published_news_article)
    get :show, id: news_article.document_identity
    assert_response :success
  end

  test "renders the news article body using govspeak" do
    news_article = create(:published_news_article, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: news_article.document_identity

    assert_select ".body", text: "body-in-html"
  end

  test "renders the news article notes to editors using govspeak" do
    news_article = create(:published_news_article, notes_to_editors: "notes-to-editors-in-govspeak")
    Govspeak::Document.stubs(:to_html).returns("\n")
    Govspeak::Document.stubs(:to_html).with("notes-to-editors-in-govspeak").returns("notes-to-editors-in-html")

    get :show, id: news_article.document_identity

    assert_select "#{notes_to_editors_selector}", text: /notes-to-editors-in-html/
  end

  test "excludes the notes to editors section if they're empty" do
    news_article = create(:published_news_article, notes_to_editors: "")
    get :show, id: news_article.document_identity
    refute_select "#{notes_to_editors_selector}"
  end

  test "shows when news article was last updated" do
    news_article = create(:published_news_article, published_at: 10.days.ago)

    get :show, id: news_article.document_identity

    assert_select "p.meta .metadata" do
      assert_select ".published_at[title='#{news_article.published_at.iso8601}']"
    end
  end

  test "show displays the image for the news article" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')
    news_article = create(:published_news_article, image: portas_review_jpg)

    get :show, id: news_article.document_identity

    assert_select ".document_view" do
      assert_select ".img img[src='#{news_article.image_url}']"
    end
  end

  test "show only displays image if there is one" do
    news_article = create(:published_news_article, image: nil)

    get :show, id: news_article.document_identity

    assert_select ".document_view" do
      refute_select ".img img"
    end
  end
end
