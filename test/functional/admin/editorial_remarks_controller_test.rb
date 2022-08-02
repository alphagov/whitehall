require "test_helper"

class Admin::EditorialRemarksControllerTest < ActionController::TestCase
  setup do
    @logged_in_user = login_as :departmental_editor
  end

  should_be_an_admin_controller

  view_test "should render the edition title and body to give context to the person rejecting" do
    edition = create(:submitted_publication, title: "edition-title", body: "edition-body")
    get :new, params: { edition_id: edition }

    assert_select "#{record_css_selector(edition)} .title", text: "edition-title"
    assert_select "#{record_css_selector(edition)} .body", text: "edition-body"
  end

  view_test "should render the editorial remark form for a statistical data set" do
    StatisticalDataSet.stubs(access_limited_by_default?: false)
    edition = create(:draft_statistical_data_set, title: "edition-title", body: "edition-body")
    get :new, params: { edition_id: edition }
    assert_select "form#new_editorial_remark"
  end

  view_test "should render the editorial remark form for a document collection" do
    edition = create(:draft_document_collection, title: "collection-title", body: "collection-body")
    get :new, params: { edition_id: edition }
    assert_select "form#new_editorial_remark"
  end

  test "should redirect to the edition" do
    edition = create(:submitted_speech)
    post :create, params: { edition_id: edition, editorial_remark: { body: "editorial-remark-body" } }
    assert_redirected_to admin_speech_path(edition)
  end

  test "should redirect to the edition remarks index page when the user has the `View move tabs to endpoints` permission" do
    @logged_in_user.permissions << "View move tabs to endpoints"
    edition = create(:submitted_speech)
    post :create, params: { edition_id: edition, editorial_remark: { body: "editorial-remark-body" } }
    assert_redirected_to admin_edition_editorial_remarks_path(edition)
  end

  test "should create an editorial remark" do
    edition = create(:submitted_publication)
    post :create, params: { edition_id: edition, editorial_remark: { body: "editorial-remark-body" } }

    edition.reload
    assert_equal 1, edition.editorial_remarks.length
    assert_equal @logged_in_user, edition.editorial_remarks.first.author
    assert_equal "editorial-remark-body", edition.editorial_remarks.first.body
  end

  view_test "should explain why the editorial remark could not be saved" do
    edition = create(:submitted_consultation)
    post :create, params: { edition_id: edition, editorial_remark: { body: "" } }
    assert_template "new"
    assert_select ".form-errors"
  end

  test "should prevent access to inaccessible editions" do
    protected_edition = create(:submitted_publication, access_limited: true)

    get :new, params: { edition_id: protected_edition.id }
    assert_response :forbidden
    get :create, params: { edition_id: protected_edition.id }
    assert_response :forbidden
  end

  test "#create should redirect to the document show page if the document is locked" do
    edition = create(:news_article, :with_locked_document)

    post :create, params: { edition_id: edition.id }

    assert_redirected_to show_locked_admin_edition_path(edition)
    assert_equal "This document is locked and cannot be edited", flash[:alert]
  end

  test "#new should redirect to the document show page if the document is locked" do
    edition = create(:news_article, :with_locked_document)

    get :new, params: { edition_id: edition.id }

    assert_redirected_to show_locked_admin_edition_path(edition)
    assert_equal "This document is locked and cannot be edited", flash[:alert]
  end

  view_test "#index should render editorial remarks in reverse chronological order" do
    edition = create(:submitted_publication)

    create(:editorial_remark, body: "Should appear second", edition: edition)
    create(:editorial_remark, body: "Should appear first", edition: edition)

    get :index, params: { edition_id: edition }

    assert_equal "Should appear first", css_select("span.body")[0].text
    assert_equal "Should appear second", css_select("span.body")[1].text
  end

  view_test "#index should render a link to add a new note" do
    edition = create(:submitted_publication)

    get :index, params: { edition_id: edition }
    assert_select "a[href=?]", "/government/admin/editions/#{edition.id}/editorial_remarks/new", text: "Add note"
  end
end
