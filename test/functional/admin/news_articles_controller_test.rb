require 'test_helper'

class Admin::NewsArticlesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :news_article
  should_allow_creating_of :news_article
  should_allow_editing_of :news_article

  should_show_document_audit_trail_for :news_article, :show
  should_show_document_audit_trail_for :news_article, :edit

  should_allow_related_policies_for :news_article
  should_allow_organisations_for :news_article
  should_allow_role_appointments_for :news_article
  should_allow_association_between_world_locations_and :news_article
  should_allow_attached_images_for :news_article
  should_be_rejectable :news_article
  should_be_publishable :news_article
  should_allow_unpublishing_for :news_article
  should_be_force_publishable :news_article
  should_be_able_to_delete_an_edition :news_article
  should_link_to_public_version_when_published :news_article
  should_not_link_to_public_version_when_not_published :news_article
  should_link_to_preview_version_when_not_published :news_article
  should_prevent_modification_of_unmodifiable :news_article
  should_allow_overriding_of_first_published_at_for :news_article
  should_have_summary :news_article
  should_have_notes_to_editors :news_article
  should_allow_scheduled_publication_of :news_article

  test "new displays news article fields" do
    get :new


  end

  test "show renders the summary" do
    draft_news_article = create(:draft_news_article, summary: "a-simple-summary")

    get :show, id: draft_news_article

    assert_select ".summary", text: "a-simple-summary"
  end

  test "should render the notes to editors using govspeak markup" do
    news_article = create(:news_article, notes_to_editors: "notes-to-editors-in-govspeak")
    govspeak_transformation_fixture default: "\n", "notes-to-editors-in-govspeak" => "notes-to-editors-in-html" do
      get :show, id: news_article
    end

    assert_select "#{notes_to_editors_selector}", text: /notes-to-editors-in-html/
  end

  test "should exclude the notes to editors section if there are not any" do
    news_article = create(:news_article, notes_to_editors: "")
    get :show, id: news_article
    refute_select "#{notes_to_editors_selector}"
  end
end
