require 'test_helper'

class Admin::DocumentSeriesGroupsControllerTest < ActionController::TestCase
  setup do
    @series = create(:document_series, :with_group)
    @group = @series.groups.first
    login_as create(:policy_writer)
  end

  should_be_an_admin_controller

  view_test 'GET #index lists the groups and documents in the series' do
    publication = create(:publication)
    @group.documents = [publication.document]
    get :index, document_series_id: @series
    assert_select 'h2', Regexp.new(@group.heading)
    assert_select 'label', Regexp.new(publication.title)
  end

  view_test "GET #index shows helpful message when a group is empty" do
    get :index, document_series_id: @series
    assert_select 'section.group p.hint', /doesn't have any documents/
  end

  view_test 'GET #new renders successfully' do
    get :new, document_series_id: @series
    assert_response :ok
  end

  def post_create(params = {})
    params.reverse_merge!(heading: 'Heading', body: '')
    post :create, document_series_id: @series, document_series_group: params
  end

  test 'POST #create creates a new group from valid data and redirects' do
    assert_difference('@series.groups.count') do
      post_create(heading: 'New group', body: 'Group body')
    end
    group = DocumentSeriesGroup.last
    assert_equal 'New group', group.heading
    assert_equal 'Group body', group.body
    assert_redirected_to admin_document_series_groups_path(@series)
  end

  view_test 'POST #create prompts for missing data if new group invalid' do
    post_create(heading: '')
    assert_response :success
    assert_select '.errors li', text: /Heading/
  end

  view_test 'GET #edit renders successfully' do
    get :edit, document_series_id: @series, id: @group
    assert_response :ok
  end

  def put_update(params)
    put :update, document_series_id: @series, id: @group,
                 document_series_group: params
  end

  test 'PUT #update modifies the group and redirects' do
    put_update(heading: 'New heading', body: 'New body')
    @group.reload
    assert_equal 'New heading', @group.heading
    assert_equal 'New body', @group.body
    assert_redirected_to admin_document_series_groups_path(@series)
  end

  view_test 'PUT #update prompts for missing data if group invalid' do
    put_update(heading: '')
    assert_response :success
    assert_select '.errors li', text: /Heading/
  end
end
