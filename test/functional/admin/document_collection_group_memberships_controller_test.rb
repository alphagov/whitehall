require 'test_helper'

class Admin::DocumentCollectionGroupMembershipsControllerTest < ActionController::TestCase
  setup do
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    login_as create(:writer)
  end

  should_be_an_admin_controller

  def id_params
    { document_collection_id: @collection, group_id: @group }
  end

  test 'POST #create adds a document to a group and redirects' do
    document = create(:publication).document
    assert_difference '@group.reload.documents.size' do
      post :create, params: id_params.merge(document_id: document.id)
    end
    assert_redirected_to admin_document_collection_groups_path(@collection)
  end

  test 'POST #create warns user when document not found' do
    post :create, params: id_params.merge(document_id: 1234, title: 'blah')
    assert_match %r[couldn't find.*blah], flash[:alert]
  end

  test 'POST #create handles invalid DocumentCollectionGroupMemberships' do
    collection_document = create(:document, document_type: 'DocumentCollection')
    post :create, params: id_params.merge(document_id: collection_document.id)
    assert_match %r[Document cannot be a document collection], flash[:alert]
  end

  def remove_params
    id_params.merge(commit: 'Remove')
  end

  def move_params
    id_params.merge(commit: 'Move')
  end

  view_test 'DELETE #destroy removes memberships and redirects when Remove clicked' do
    memberships = [create(:document_collection_group_membership),
                   create(:document_collection_group_membership)]
    @group.memberships << memberships
    assert_difference '@group.reload.memberships.size', -1 do
      delete :destroy, params: remove_params.merge(memberships: [memberships.first.id])
    end
    assert_redirected_to admin_document_collection_groups_path(@collection)
    assert_match %r[1 document removed], flash[:notice]
  end

  test 'DELETE #destroy sets flash message if no documents selected' do
    delete :destroy, params: remove_params
    assert_match %r[select one or more documents]i, flash[:alert]
  end

  test 'DELETE #destroy moves documents and redirects when Move clicked' do
    memberships = [create(:document_collection_group_membership),
                   create(:document_collection_group_membership)]
    @group.memberships << memberships
    new_group = build(:document_collection_group)
    @collection.groups << new_group
    assert_difference 'new_group.reload.memberships.size', 1 do
      assert_difference '@group.reload.memberships.size', -1 do
        delete :destroy, params: move_params.merge(
          memberships: [memberships.first.id],
          new_group_id: new_group.id
        )
      end
    end
    assert_redirected_to admin_document_collection_groups_path(@collection)
    assert_match %r[1 document moved to '#{new_group.heading}'], flash[:notice]
  end
end
