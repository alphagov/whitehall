require "test_helper"

class Admin::GenericEditionsController::PolticalDocumentsTest < ActionController::TestCase
  tests Admin::NewsArticlesController
  enable_url_helpers

  setup do
    login_as :writer
  end

  view_test "displays the history mode form control for managing editor users" do
    current_government = create(:current_government)
    login_as :managing_editor
    published_edition = create(:published_news_article, first_published_at: 2.days.ago)
    new_draft = create(:news_article, document: published_edition.document, first_published_at: 2.days.ago)
    get :edit, params: { id: new_draft }
    assert_select "#edition_political input[type='checkbox'][name='edition[government_id]'][value='#{current_government.id}']"
  end

  test "gds editors can override the government associated with an edition" do
    current_government = create(:current_government)
    previous_government = create(:previous_government)
    published_edition = create(:published_news_article, first_published_at: 2.days.ago, government: current_government)
    new_draft = create(:news_article, document: published_edition.document, first_published_at: 2.days.ago)

    put :update, params: { id: new_draft, edition: { government_id: previous_government.id } }

    assert_redirected_to admin_edition_path(new_draft)
    assert_equal previous_government, new_draft.reload.government
  end

  view_test "doesn't display the political checkbox for non-privileged users " do
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    get :edit, params: { id: new_draft }
    assert_select "#edition_political", count: 0
  end

  view_test "doesn't display the political checkbox on creation" do
    login_as :managing_editor
    get :new
    assert_select "#edition_political", count: 0
  end

  def edit_historic_document
    previous_government = create(:previous_government, name: "old")
    create(:current_government, name: "new")

    published_edition = create(:published_news_article, first_published_at: 3.years.ago)
    new_draft = create(:news_article, government: previous_government, first_published_at: 3.years.ago, document: published_edition.document)

    get :edit, params: { id: new_draft }
  end

  view_test "doesn't let non-GDS users edit historic documents" do
    login_as :departmental_editor
    edit_historic_document
    assert_response :redirect
  end

  view_test "doesn't let managing editors edit historic documents" do
    login_as :managing_editor
    edit_historic_document
    assert_response :redirect
  end

  view_test "lets GDS editors edit historic documents" do
    login_as :gds_editor
    edit_historic_document
    assert_response :success
  end
end

class Admin::GenericEditionsController::PolticalDocumentsTestWhenCannotBeMarkedPolitical < ActionController::TestCase
  tests Admin::WorldwideOrganisationsController

  setup do
    login_as :writer
  end

  view_test "does not display the political checkbox for editions which cannot be marked political" do
    published_edition = create(:published_worldwide_organisation)
    new_draft = create(:worldwide_organisation, document: published_edition.document)
    get :edit, params: { id: new_draft }
    assert_select "#edition_political", count: 0
  end
end
