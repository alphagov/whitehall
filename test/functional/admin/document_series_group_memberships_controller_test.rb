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

  view_test 'DELETE #destroy removes documents from group and redirects' do
    documents = [create(:publication), create(:publication)].map(&:document)
    @group.documents << documents
    assert_difference '@group.documents.size', -1 do
      delete :destroy, id_params.merge(documents: [documents.first.id])
    end
    assert_redirected_to admin_document_series_groups_path(@series)
    assert_match /1 document removed/, flash[:notice]
  end

  test 'DELETE #destroy sets flash message if no documents selected' do
    delete :destroy, id_params
    assert_match /select one or more documents/i, flash[:alert]
  end
end
