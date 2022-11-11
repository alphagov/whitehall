require "test_helper"

class Admin::LegacyNewsArticlesControllerTest < ActionController::TestCase
  tests Admin::NewsArticlesController

  setup do
    login_as :writer
  end

  legacy_should_be_an_admin_controller

  legacy_should_allow_creating_of :news_article
  legacy_should_allow_editing_of :news_article

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

private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:news_article_type).reverse_merge(
      news_article_type_id: NewsArticleType::GovernmentResponse,
    )
  end
end
