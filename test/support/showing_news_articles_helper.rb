module ShowingNewsArticlesHelper
  def should_show_news_articles
    should_show_related_policies_and_topics_for :news_article
    should_show_the_countries_associated_with :news_article
    should_display_inline_images_for :news_article
    should_display_lead_image_for :news_article
    should_show_change_notes :news_article

    test "shows published news article" do
      news_article = create(:published_news_article)
      get :show, id: news_article.document
      assert_response :success
    end

    test "renders the news article summary from plain text" do
      news_article = create(:published_news_article, summary: 'plain text & so on')
      get :show, id: news_article.document

      assert_select ".summary", text: "plain text &amp; so on"
    end

    test "renders the news article body using govspeak" do
      news_article = create(:published_news_article, body: "body-in-govspeak")
      govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
        get :show, id: news_article.document
      end

      assert_select ".body", text: "body-in-html"
    end

    test "renders the news article notes to editors using govspeak" do
      news_article = create(:published_news_article, notes_to_editors: "notes-to-editors-in-govspeak")
      govspeak_transformation_fixture default: "\n", "notes-to-editors-in-govspeak" => "notes-to-editors-in-html" do
        get :show, id: news_article.document
      end

      assert_select "#{notes_to_editors_selector}", text: /notes-to-editors-in-html/
    end

    test "excludes the notes to editors section if they're empty" do
      news_article = create(:published_news_article, notes_to_editors: "")
      get :show, id: news_article.document
      refute_select "#{notes_to_editors_selector}"
    end

    test "shows when updated news article was first published and last updated" do
      news_article = create(:published_news_article, published_at: 10.days.ago)

      editor = create(:departmental_editor)
      updated_news_article = news_article.create_draft(editor)
      updated_news_article.change_note = "change-note"
      updated_news_article.publish_as(editor, force: true)

      get :show, id: updated_news_article.document

      assert_select ".meta" do
        assert_select ".published-at[title='#{news_article.first_published_at.iso8601}']"
        assert_select ".published-at[title='#{updated_news_article.published_at.iso8601}']"
      end
    end
  end
end