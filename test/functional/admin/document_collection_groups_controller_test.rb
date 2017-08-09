require 'test_helper'

class Admin::DocumentCollectionGroupsControllerTest < ActionController::TestCase
  setup do
    @collection = create(:document_collection, :with_group)
    @group = @collection.groups.first
    login_as create(:writer)
  end

  should_be_an_admin_controller

  view_test 'GET #index lists the groups and documents in the collection' do
    publication = create(:publication)
    @group.documents = [publication.document]
    get :index, params: { document_collection_id: @collection }
    assert_select 'h2', Regexp.new(@group.heading)
    assert_select 'label', Regexp.new(publication.title)
  end

  view_test "GET #index shows helpful message when a group is empty" do
    get :index, params: { document_collection_id: @collection }
    assert_select 'section.group .no-content', /No documents in this group/
  end

  view_test 'GET #index lets you move docs to another group' do
    @group.documents << create(:publication).document
    @collection.groups << build(:document_collection_group)
    group1, group2 = @collection.groups
    get :index, params: { document_collection_id: @collection }
    assert_select 'section.group' do
      assert_select "option[value='#{group1.id}']", count: 0
      assert_select "option[value='#{group2.id}']", group2.heading
    end
  end

  view_test 'GET #index shows a warning if > 50 documents in collection' do
    @group.documents = create_list(:document, 51)
    get :index, document_collection_id: @collection
    assert_response :ok
    assert_select '.alert-info', text: /it may be slow or impossible to update/
  end

  view_test 'GET #index does not show a warning if <= 50 documents in collection' do
    @group.documents = create_list(:document, 50)
    get :index, document_collection_id: @collection
    assert_response :ok
    assert_select '.alert-info', false, text: /it may be slow or impossible to update/
  end

  view_test 'GET #new renders successfully' do
    get :new, params: { document_collection_id: @collection }
    assert_response :ok
  end

  def post_create(params = {})
    params.reverse_merge!(heading: 'Heading', body: '')
    post :create, params: { document_collection_id: @collection, document_collection_group: params }
  end

  test 'POST #create creates a new group from valid data and redirects' do
    assert_difference('@collection.groups.count') do
      post_create(heading: 'New group', body: 'Group body')
    end
    group = DocumentCollectionGroup.last
    assert_equal 'New group', group.heading
    assert_equal 'Group body', group.body
    assert_redirected_to admin_document_collection_groups_path(@collection)
  end

  view_test 'POST #create prompts for missing data if new group invalid' do
    post_create(heading: '')
    assert_response :success
    assert_select '.errors li', text: /Heading/
  end

  view_test 'GET #edit renders successfully' do
    get :edit, params: { document_collection_id: @collection, id: @group }
    assert_response :ok
  end

  def put_update(params)
    put :update, params: { document_collection_id: @collection, id: @group, document_collection_group: params }
  end

  test 'PUT #update modifies the group and redirects' do
    put_update(heading: 'New heading', body: 'New body')
    @group.reload
    assert_equal 'New heading', @group.heading
    assert_equal 'New body', @group.body
    assert_redirected_to admin_document_collection_groups_path(@collection)
  end

  view_test 'PUT #update prompts for missing data if group invalid' do
    put_update(heading: '')
    assert_response :success
    assert_select '.errors li', text: /Heading/
  end

  view_test "GET #delete explains you can't delete groups that have documents" do
    @group.documents = [create(:publication).document]
    @collection.groups << build(:document_collection_group)
    get :delete, params: { document_collection_id: @collection, id: @group }
    assert_select 'div.alert', /can’t delete a group.*documents/
    assert_select 'input[type="submit"]', count: 0
  end

  view_test "GET #delete explains you can't delete the last group" do
    get :delete, params: { document_collection_id: @collection, id: @group }
    assert_select 'div.alert', /can’t\s+delete the last/
    assert_select 'input[type="submit"]', count: 0
  end

  view_test 'GET #delete allows you to delete an empty group' do
    @collection.groups << build(:document_collection_group)
    get :delete, params: { document_collection_id: @collection, id: @group }
    assert_select 'input[type="submit"][value="Delete"]'
  end

  view_test 'DELETE #destroy deletes group and redirects' do
    assert_difference '@collection.groups.count', -1 do
      delete :destroy, params: { document_collection_id: @collection, id: @group }
    end
    assert_redirected_to admin_document_collection_groups_path(@collection)
  end

  test "POST #update_memberships saves the order of group members" do
    given_two_groups_with_documents
    post :update_memberships, params: {
      document_collection_id: @collection.id,
      groups: {
        0 => {
          id: @group_1.id,
          document_ids: [
            @doc_1_2.id,
            @doc_1_1.id
          ],
          order: 0
        }
      }
    }
    assert_equal [@doc_1_2, @doc_1_1], @group_1.reload.documents
  end

  test "POST #update_memberships saves the order of groups" do
    given_two_groups_with_documents
    post :update_memberships, params: {
      document_collection_id: @collection.id,
      groups: {
        0 => {
          id: @group_1.id,
          document_ids: [
            @doc_1_1.id,
            @doc_1_2.id
          ],
          order: 1
        },
        1 => {
          id: @group_2.id,
          document_ids: [
            @doc_2_1.id,
            @doc_2_2.id
          ],
          order: 0
        }
      }
    }
    assert_response :success
    assert_equal [@group_2.id, @group_1.id], @collection.reload.groups.pluck(:id)
  end

  test "POST #update_memberships should cope with duplicate documents in group" do
    given_two_groups_with_documents
    post :update_memberships,
      document_collection_id: @collection.id,
      groups: {
        0 => {
          id: @group_1.id,
          document_ids: [
            @doc_1_1.id,
            @doc_1_1.id
          ],
          order: 0
        }
      }
    assert_equal [@doc_1_1], @group_1.reload.documents
  end

  test "POST #update_memberships should support moving memberships between groups" do
    given_two_groups_with_documents
    post :update_memberships,
      document_collection_id: @collection.id,
      groups: {
        0 => {
          id: @group_1.id,
          document_ids: [
            @doc_1_1.id
          ],
          order: 0
        },
        1 => {
          id: @group_2.id,
          document_ids: [
            @doc_1_2.id,
            @doc_2_1.id,
            @doc_2_2.id
          ],
          order: 1
        }
      }
    assert @group_2.reload.documents.include?(@doc_1_2)
  end

  test "POST #update_memberships should handle empty groups" do
    given_two_groups_with_documents

    post :update_memberships, params: {
      document_collection_id: @collection.id,
      groups: {
        0 => {
          id: @group_1.id,
          document_ids: [
            @doc_1_1.id,
            @doc_1_2.id,
            @doc_2_1.id,
            @doc_2_2.id
          ],
          order: 0
        },
        1 => {
          id: @group_2.id,
          order: 1
        }
      }
    }

    assert_response :success
    assert_equal [@doc_1_1, @doc_1_2, @doc_2_1, @doc_2_2], @group_1.reload.documents
    assert_empty @group_2.reload.documents
  end

  def given_two_groups_with_documents
    @group_1 = build(:document_collection_group)
    @group_2 = build(:document_collection_group)
    @collection.update_attribute :groups, [@group_1, @group_2]

    @group_1.documents << @doc_1_1 = create(:document)
    @group_1.documents << @doc_1_2 = create(:document)
    @group_2.documents << @doc_2_1 = create(:document)
    @group_2.documents << @doc_2_2 = create(:document)
  end
end
