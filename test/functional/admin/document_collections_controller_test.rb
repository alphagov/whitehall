require "test_helper"

class Admin::DocumentCollectionsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "new should show fields for creating a collection" do
    organisation = create(:organisation)

    get :new, organisation_id: organisation.id

    assert_select "form[action=?]", admin_organisation_document_collections_path(organisation) do
      assert_select "input[type=text][name=?]", "document_collection[name]"
    end
  end

  test "create should save a new collection" do
    organisation = create(:organisation)

    post :create, organisation_id: organisation.id, document_collection: {name: "collection-name"}

    assert_equal 1, organisation.document_collections.count
    document_collection = organisation.document_collections.first
    assert_equal "collection-name", document_collection.name
    assert_redirected_to admin_organisation_document_collection_path(organisation, document_collection)
  end

  test "create should allow errors to be corrected" do
    organisation = create(:organisation)

    post :create, organisation_id: organisation.id, document_collection: {name: ""}

    assert_response :success
    assert_equal 0, organisation.document_collections.count
    assert_select "form" do
      assert_select ".field_with_errors input[name=?]", "document_collection[name]"
    end
  end

  test "edit should show a form for editing the collection" do
    document_collection = create(:document_collection)
    organisation = document_collection.organisation

    get :edit, organisation_id: organisation.id,
               id: document_collection.id

    form_path = admin_organisation_document_collection_path(organisation, document_collection)
    assert_select "form[action=?]", form_path do
      assert_select "input[type=text][name=?]", "document_collection[name]"
    end
  end

  test "update should update a collection" do
    document_collection = create(:document_collection, name: "old-name")
    organisation = document_collection.organisation

    put :update, organisation_id: organisation.id,
                 id: document_collection.id,
                 document_collection: {name: "new-name"}

    assert_equal "new-name", document_collection.reload.name
    assert_redirected_to admin_organisation_document_collection_path(organisation, document_collection)
  end

  test "update should show errors updating a collection" do
    document_collection = create(:document_collection, name: "old-name")
    organisation = document_collection.organisation

    put :update, organisation_id: organisation.id,
                 id: document_collection.id,
                 document_collection: {name: ""}

    assert_equal "old-name", document_collection.reload.name

    assert_select "form" do
      assert_select ".field_with_errors input[name=?]", "document_collection[name]"
    end
  end
end
