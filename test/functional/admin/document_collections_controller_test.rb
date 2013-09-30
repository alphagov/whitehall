require "test_helper"

class Admin::DocumentCollectionsControllerTest < ActionController::TestCase
  setup do
    @organisation_1 = create(:organisation)

    @user = create(:policy_writer)
    login_as @user
  end

  should_be_an_admin_controller
  should_allow_related_policies_for :document_collection
  should_allow_organisations_for :document_collection

  view_test 'GET #show displays the document collection' do
    collection = create(:document_collection,
      title: "collection-title",
      summary: "the summary"
    )

    get :show, id: collection

    assert_select "h1", "collection-title"
    assert_select ".summary", "the summary"
  end

  view_test "GET #new renders document collection form" do
    get :new

    assert_select "form[action=?]", admin_document_collections_path do
      assert_select "input[type=text][name=?]", "edition[title]"
      assert_select "textarea[name=?]", "edition[summary]"
      assert_select "textarea[name=?]", "edition[body]"
    end
  end

  test "POST #create saves the document collection" do
    post :create, edition: {
          title: "collection-title",
          summary: "collection-summary",
          body: "collection-body",
          lead_organisation_ids: [@organisation_1.id]
        }

    assert_equal 1, DocumentCollection.count
    document_collection = DocumentCollection.first
    assert_equal "collection-title", document_collection.title
    assert_equal "collection-summary", document_collection.summary
    assert_equal "collection-body", document_collection.body
    assert document_collection.groups.present?, 'should have a group'
  end

  view_test "POST #create with invalid params re-renders form the with errors" do
    post :create, edition: { title: "" }

    assert_response :success
    assert_equal 0, DocumentCollection.count

    assert_select "form .field_with_errors input[name=?]", "edition[title]"
  end

  view_test "GET #edit renders the edit form for the document collection" do
    document_collection = create(:document_collection)

    get :edit, id: document_collection

    assert_select "form[action=?]", admin_document_collection_path(document_collection) do
      assert_select "input[name='edition[slug]'][value=?]", document_collection.slug
      assert_select "input[name='edition[title]'][value=?]", document_collection.title
      assert_select "textarea[name='edition[summary]']", text: document_collection.summary
      assert_select "textarea[name='edition[body]']", text: document_collection.body
    end
  end

  test "PUT #update updates the document collection" do
    document_collection = create(:document_collection, title: "old-title")

    put :update, id: document_collection, edition: { title: "new-title" }

    assert_equal "new-title", document_collection.reload.title
    assert_response :redirect
  end

  view_test "PUT #update with invalid params re-renders the form with errors" do
    document_collection = create(:document_collection, title: "old-title")
    put :update, id: document_collection, edition: {title: ""}

    assert_equal "old-title", document_collection.reload.title

    assert_select "form" do
      assert_select ".field_with_errors input[name=?]", "edition[title]"
    end
  end

  test "DELETE #destroy deletes the document collection" do
    document_collection = create(:document_collection)
    delete :destroy, id: document_collection

    refute DocumentCollection.exists?(document_collection)
    assert_response :redirect
  end

end
