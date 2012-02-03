require 'test_helper'

class Admin::NewsArticlesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :news_article
  should_allow_creating_of :news_article
  should_allow_editing_of :news_article

  should_allow_organisations_for :news_article
  should_allow_ministerial_roles_for :news_article
  should_allow_association_between_countries_and :news_article
  should_be_rejectable :news_article
  should_be_publishable :news_article
  should_be_force_publishable :news_article
  should_be_able_to_delete_a_document :news_article
  should_link_to_public_version_when_published :news_article
  should_not_link_to_public_version_when_not_published :news_article
  should_prevent_modification_of_unmodifiable :news_article
  should_allow_overriding_of_first_published_at_for :news_article

  test "new displays news article fields" do
    get :new

    assert_select "form#document_new" do
      assert_select "select[name*='document[related_document_identity_ids]']"
      assert_select "textarea.previewable.govspeak[name='document[notes_to_editors]']"
    end
  end

  test "create should create a new news article" do
    first_policy = create(:published_policy)
    second_policy = create(:published_policy)
    attributes = attributes_for(:news_article)

    post :create, document: attributes.merge(
      summary: "news-article-summary",
      notes_to_editors: "notes-to-editors",
      related_document_identity_ids: [first_policy.document_identity.id, second_policy.document_identity.id]
    )

    created_news_article = NewsArticle.last
    assert_equal "news-article-summary", created_news_article.summary
    assert_equal "notes-to-editors", created_news_article.notes_to_editors
    assert_equal [first_policy, second_policy], created_news_article.related_policies
  end

  test "update should save modified news article attributes" do
    first_policy = create(:published_policy)
    second_policy = create(:published_policy)
    news_article = create(:news_article, related_policies: [first_policy])

    put :update, id: news_article, document: {
      summary: "new-news-article-summary",
      notes_to_editors: "new-notes-to-editors",
      related_document_identity_ids: [second_policy.document_identity.id]
    }

    saved_news_article = news_article.reload
    assert_equal "new-news-article-summary", saved_news_article.summary
    assert_equal "new-notes-to-editors", saved_news_article.notes_to_editors
    assert_equal [second_policy], saved_news_article.related_policies
  end

  test "update should remove all related documents if none in params" do
    policy = create(:published_policy)

    news_article = create(:news_article, related_policies: [policy])

    put :update, id: news_article, document: {}

    news_article.reload
    assert_equal [], news_article.related_policies
  end

  test "show renders the summary" do
    draft_news_article = create(:draft_news_article, summary: "a-simple-summary")

    get :show, id: draft_news_article

    assert_select ".summary", text: "a-simple-summary"
  end

  test "should render the notes to editors using govspeak markup" do
    news_article = create(:news_article, notes_to_editors: "notes-to-editors-in-govspeak")
    Govspeak::Document.stubs(:to_html).returns("\n")
    Govspeak::Document.stubs(:to_html).with("notes-to-editors-in-govspeak").returns("notes-to-editors-in-html")

    get :show, id: news_article

    assert_select "#{notes_to_editors_selector}", text: /notes-to-editors-in-html/
  end

  test "should exclude the notes to editors section if there aren't any" do
    news_article = create(:news_article, notes_to_editors: "")
    get :show, id: news_article
    refute_select "#{notes_to_editors_selector}"
  end

  test "show displays the image caption for the news article" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')
    news_article = create(:published_news_article, image: portas_review_jpg, image_alt_text: 'candid-photo', image_caption: "image caption")

    get :show, id: news_article

    assert_select "figure.image figcaption", "image caption"
  end


  test "new displays news article image field" do
    get :new

    assert_select "form#document_new" do
      assert_select "input[name='document[image]'][type='file']"
    end
  end

  test "creating a news article should store image" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')
    attributes = attributes_for(:news_article, image: portas_review_jpg, image_alt_text: 'candid-photo')

    post :create, document: attributes

    assert news_article = NewsArticle.last
    refute_nil news_article.image
    assert_equal "portas-review.jpg", news_article.carrierwave_image
  end

  test "creating a news article should store image caption" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')
    attributes = attributes_for(:news_article, image: portas_review_jpg, image_alt_text: 'candid-photo', image_caption: "image caption")

    post :create, document: attributes

    assert news_article = NewsArticle.last
    assert_equal "image caption", news_article.image_caption
  end

  test "creating a news article with invalid data and an image should remember the uploaded image" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')

    post :create, document: attributes_for(:news_article,
      title: "",
      image: portas_review_jpg
    )

    assert_select "form#document_new" do
      assert_select "input[name='document[image_cache]'][type='hidden'][value$='portas-review.jpg']"
      assert_select ".already_uploaded", text: "portas-review.jpg already uploaded"
    end
  end

  test "creating a news article with invalid data should not show any existing image" do
    attributes = attributes_for(:news_article, image: fixture_file_upload('portas-review.jpg'))

    post :create, document: attributes.merge(title: '')

    refute_select "figure.image img"
  end

  test "editing displays news article image field" do
    news_article = create(:news_article)

    get :edit, id: news_article

    assert_select "form#document_edit" do
      assert_select "input[name='document[image]'][type='file']"
    end
  end

  test "editing news article with existing image displays image" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')
    news_article = create(:news_article, image: portas_review_jpg, image_alt_text: 'candid-photo')

    get :edit, id: news_article

    assert_select "form#document_edit" do
      assert_select ".img img[src='#{news_article.image_url}']"
    end
  end

  test "editing news article without an image doesn't display image" do
    news_article = create(:news_article)

    get :edit, id: news_article

    assert_select "form#document_edit" do
      assert_select "figure.image", count: 0
    end
  end

  test "updating a news article should store image" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')
    news_article = create(:news_article)

    put :update, id: news_article, document: news_article.attributes.merge(
      image: portas_review_jpg, image_alt_text: 'candid-photo'
    )

    news_article.reload
    refute_nil news_article.image
    assert_equal "portas-review.jpg", news_article.carrierwave_image
  end

  test "updating a news article with invalid data and an image should remember the uploaded image" do
    news_article = create(:news_article)
    portas_review_jpg = fixture_file_upload('portas-review.jpg')

    put :update, id: news_article, document: attributes_for(:news_article,
      title: "",
      image: portas_review_jpg
    )

    assert_select "form#document_edit" do
      assert_select "input[name='document[image_cache]'][type='hidden'][value$='portas-review.jpg']"
      assert_select ".already_uploaded", text: "portas-review.jpg already uploaded"
    end
  end

  test "show displays the stored image" do
    portas_review_jpg = fixture_file_upload('portas-review.jpg')
    news_article = create(:news_article, image: portas_review_jpg, image_alt_text: 'candid-photo')

    get :show, id: news_article

    assert_select "figure.image img[src='#{news_article.image_url}'][alt='#{news_article.image_alt_text}']"
  end

  test "show only displays image if there is one" do
    news_article = create(:news_article, image: nil)

    get :show, id: news_article

    refute_select "figure.image img"
  end
end
