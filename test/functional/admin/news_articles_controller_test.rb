require "test_helper"

class Admin::NewsArticlesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  legacy_should_allow_creating_of :news_article
  legacy_should_allow_editing_of :news_article

  legacy_should_allow_speed_tagging_of :news_article
  legacy_should_allow_setting_first_published_at_during_speed_tagging :news_article
  legacy_should_allow_organisations_for :news_article
  legacy_should_allow_role_appointments_for :news_article
  legacy_should_allow_association_between_world_locations_and :news_article
  legacy_should_allow_attached_images_for :news_article
  legacy_should_prevent_modification_of_unmodifiable :news_article
  legacy_should_allow_overriding_of_first_published_at_for :news_article
  legacy_should_have_summary :news_article
  legacy_should_allow_scheduled_publication_of :news_article
  legacy_should_allow_access_limiting_of :news_article
  legacy_should_allow_association_with_topical_events :news_article

  view_test "new displays news article fields" do
    get :new

    assert_select "form#new_edition" do
      assert_select "select[name*='edition[news_article_type_id']"
    end
  end

  view_test "show renders the summary" do
    draft_news_article = create(:draft_news_article, summary: "a-simple-summary")
    stub_publishing_api_expanded_links_with_taxons(draft_news_article.content_id, [])

    get :show, params: { id: draft_news_article }

    assert_select ".page-header .lead", text: "a-simple-summary"
  end

  test "edit should redirect to index page if document is locked" do
    edition = create(:news_article, :with_locked_document)
    get :edit, params: { id: edition }

    assert_redirected_to show_locked_admin_edition_path(edition)
  end

  test "update should redirect to index page if document is locked" do
    edition = create(:news_article, :with_locked_document)
    put :update, params: { id: edition }

    assert_redirected_to show_locked_admin_edition_path(edition)
  end

  test "destroy should redirect to index page if document is locked" do
    edition = create(:news_article, :with_locked_document)
    delete :destroy, params: { id: edition }

    assert_redirected_to show_locked_admin_edition_path(edition)
  end

private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:news_article_type).reverse_merge(
      news_article_type_id: NewsArticleType::GovernmentResponse,
    )
  end
end
