require "test_helper"

class StatisticalDataSetsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'show displays published statistical data set' do
    published_statistical_data_set = create(:published_statistical_data_set)
    get :show, id: published_statistical_data_set.document
    assert_select '.title', text: published_statistical_data_set.title
  end

  test 'index should display a list of all published statistical data sets' do
    create(:published_statistical_data_set)
    create(:draft_statistical_data_set)
    get :index
    assert_select '.statistical_data_set', count: 1
  end
end