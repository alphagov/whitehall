require 'test_helper'

class Admin::DocumentSeriesGroupsControllerTest < ActionController::TestCase
  def post_create(params = {})
    params.reverse_merge!(heading: 'Heading', body: '')
    post :create, document_series_id: @series, document_series_group: params
  end

  setup do
    @series = create(:document_series, :with_group)
    login_as create(:policy_writer)
  end

  should_be_an_admin_controller

  view_test 'GET #new renders successfully' do
    get :new, document_series_id: @series
    assert_response :ok
  end

  test 'POST #create creates a new group from valid data and redirects' do
    assert_difference('@series.groups.count') do
      post_create(heading: 'New group', body: 'Group body')
    end
    group = DocumentSeriesGroup.last
    assert_equal 'New group', group.heading
    assert_equal 'Group body', group.body
    assert_redirected_to admin_document_series_documents_path(@series)
  end

  view_test 'POST #create prompts for missing data if new group invalid' do
    post_create(heading: '')
    assert_response :success
    assert_select '.errors li', text: /Heading/
  end
end
