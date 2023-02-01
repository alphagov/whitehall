require "test_helper"

class Admin::LegacyDocumentCollectionsControllerTest < ActionController::TestCase
  tests Admin::DocumentCollectionsController
  include TaxonomyHelper

  setup do
    @organisation = create(:organisation)

    @user = create(:writer)
    login_as @user
  end

  legacy_should_be_an_admin_controller
  legacy_should_allow_organisations_for :document_collection

  view_test "GET #new renders document collection form" do
    get :new

    assert_select "form[action=?]", admin_document_collections_path do
      assert_select "input[type=text][name=?]", "edition[title]"
      assert_select "textarea[name=?]", "edition[summary]"
      assert_select "textarea[name=?]", "edition[body]"
    end
  end

  test "POST #create saves the document collection" do
    post :create,
         params: {
           edition: {
             title: "collection-title",
             summary: "collection-summary",
             body: "collection-body",
             lead_organisation_ids: [@organisation.id],
             previously_published: false,
           },
         }

    assert_equal 1, DocumentCollection.count
    document_collection = DocumentCollection.first
    assert_equal "collection-title", document_collection.title
    assert_equal "collection-summary", document_collection.summary
    assert_equal "collection-body", document_collection.body
    assert document_collection.groups.present?, "should have a group"
  end

  view_test "POST #create with invalid params re-renders form the with errors" do
    post :create, params: { edition: { title: "" } }

    assert_response :success
    assert_equal 0, DocumentCollection.count

    assert_select "form .field_with_errors input[name=?]", "edition[title]"
  end

  view_test "GET #edit renders the edit form for the document collection" do
    document_collection = create(:document_collection)

    get :edit, params: { id: document_collection }

    assert_select "form[action=?]", admin_document_collection_path(document_collection) do
      assert_select "input[name='edition[slug]'][value=?]", document_collection.slug
      assert_select "input[name='edition[title]'][value=?]", document_collection.title
      assert_select "textarea[name='edition[summary]']", text: document_collection.summary
      assert_select "textarea[name='edition[body]']", text: document_collection.body
    end
  end

  test "PUT #update updates the document collection" do
    document_collection = create(:document_collection, title: "old-title")

    put :update, params: { id: document_collection, edition: { title: "new-title" } }

    assert_equal "new-title", document_collection.reload.title
    assert_response :redirect
  end

  view_test "PUT #update with invalid params re-renders the form with errors" do
    document_collection = create(:document_collection, title: "old-title")
    put :update, params: { id: document_collection, edition: { title: "" } }

    assert_equal "old-title", document_collection.reload.title

    assert_select "form" do
      assert_select ".field_with_errors input[name=?]", "edition[title]"
    end
  end

  test "DELETE #destroy deletes the document collection" do
    document_collection = create(:document_collection)
    delete :destroy, params: { id: document_collection }

    assert_not DocumentCollection.exists?(document_collection.id)
    assert_response :redirect
  end
end
