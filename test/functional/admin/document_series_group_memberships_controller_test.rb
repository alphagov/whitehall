require 'test_helper'

class Admin::DocumentSeriesGroupMembershipsControllerTest < ActionController::TestCase
  setup do
    @series = create(:document_series, :with_group)
    @group = @series.groups.first
    login_as create(:policy_writer)
  end

  should_be_an_admin_controller

  def id_params
    { document_series_id: @series, group_id: @group }
  end

  test 'POST #create adds a document to a group and redirects' do
    document = create(:publication).document
    assert_difference '@group.documents.size' do
      post :create, id_params.merge(document_id: document.id)
    end
    assert_redirected_to admin_document_series_groups_path(@series)
  end

  test 'POST #create warns user when document not found' do
    post :create, id_params.merge(document_id: 1234, title: 'blah')
    assert_match /couldn't find.*blah/, flash[:alert]
  end

  def remove_params
    id_params.merge(commit: 'Remove')
  end

  def move_params
    id_params.merge(commit: 'Move')
  end

  view_test 'DELETE #destroy removes documents and redirects when Remove clicked' do
    documents = [create(:publication), create(:publication)].map(&:document)
    @group.documents << documents
    assert_difference '@group.documents.size', -1 do
      delete :destroy, remove_params.merge(documents: [documents.first.id])
    end
    assert_redirected_to admin_document_series_groups_path(@series)
    assert_match /1 document removed/, flash[:notice]
  end

  test 'DELETE #destroy sets flash message if no documents selected' do
    delete :destroy, remove_params
    assert_match /select one or more documents/i, flash[:alert]
  end

  test 'DELETE #destroy moves documents and redirects when Move clicked' do
    documents = [create(:publication), create(:publication)].map(&:document)
    @group.documents << documents
    new_group = build(:document_series_group)
    @series.groups << new_group
    assert_difference 'new_group.documents.size', 1 do
      assert_difference '@group.documents.size', -1 do
        delete :destroy, move_params.merge(
          documents: [documents.first.id],
          new_group_id: new_group.id
        )
      end
    end
    assert_redirected_to admin_document_series_groups_path(@series)
    assert_match /1 document moved to '#{new_group.heading}'/, flash[:notice]
  end
end
