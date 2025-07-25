require "test_helper"

class Admin::NewsArticlesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :news_article
  should_allow_editing_of :news_article

  should_allow_lead_and_supporting_organisations_for :news_article
  should_allow_role_appointments_for :news_article
  should_allow_association_between_world_locations_and :news_article
  should_allow_association_with_worldwide_organisations :world_news_story, edition_parent_type: :news_article, factory_name: :news_article_world_news_story, required: true
  should_allow_overriding_of_first_published_at_for :news_article
  should_have_summary :news_article
  should_allow_scheduled_publication_of :news_article
  should_allow_access_limiting_of :news_article
  should_allow_association_with_topical_events :news_article
  should_render_govspeak_history_and_fact_checking_tabs_for :news_article

  view_test "new displays news article fields" do
    get :new

    assert_select "form#new_edition" do
      assert_select "select[name*='edition[news_article_type_id']"
    end
  end

  view_test "edit displays news article field and guidance" do
    news_article = create(:news_article)

    get :edit, params: { id: news_article }

    assert_select "form#edit_edition" do
      assert_select "select[name*='edition[news_article_type_id']"
      assert_select ".js-app-view-edition-form__subtype-format-advice", text: "Use this subformat for… Unedited press releases as sent to the media, and official statements from the organisation or a minister.Do not use for: statements to Parliament. Use the “Speech” format for those."
    end
  end

  view_test "show renders the summary" do
    draft_news_article = create(:draft_news_article, summary: "a-simple-summary")
    stub_publishing_api_expanded_links_with_taxons(draft_news_article.content_id, [])

    get :show, params: { id: draft_news_article }

    assert_select ".app-view-summary__document-summary .govuk-body-lead", text: "a-simple-summary"
  end

private

  def controller_attributes_for(edition_type, attributes = {})
    if edition_type == :world_news_story
      world_location = create(:world_location)

      controller_attributes_for(:news_article, attributes:).except(:lead_organisation_ids, :news_article_type, :news_article_type_id).reverse_merge(
        news_article_type_id: NewsArticleType::WorldNewsStory,
        world_location_ids: [world_location.id],
      )
    else
      super.except(:news_article_type).reverse_merge(
        news_article_type_id: NewsArticleType::GovernmentResponse,
      )
    end
  end
end
