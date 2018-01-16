require 'test_helper'

class Admin::GovernmentsControllerTest < ActionController::TestCase
  setup do
    @government = FactoryBot.create(:government)
  end

  should_be_an_admin_controller

  %i[new edit prepare_to_close].each do |action_method|
    test "GDS admin permission required to access #{action_method}" do
      login_as :gds_editor
      get action_method, params: { id: @government.id }
      assert_response 403
    end
  end

  %i[create update close].each do |action_method|
    test "GDS admin permission required to access #{action_method}" do
      login_as :gds_editor
      post action_method, params: { id: @government.id }
      assert_response 403
    end
  end

  view_test "new should have the default start date of today" do
    login_as :gds_admin
    get :new
    assert_select "input[name='government[start_date]'][value='#{Date.today}']"
  end

  test "#close sets the end date to today" do
    login_as :gds_admin
    post :close, params: { id: @government.id }
    @government.reload
    assert_equal Date.today, @government.end_date
  end

  test "#close doesn't overwrite an end date if there is one" do
    login_as :gds_admin
    @government.update(end_date: 10.days.ago.to_date)
    post :close, params: { id: @government.id }
    @government.reload
    assert_equal 10.days.ago.to_date, @government.end_date
  end

  test "#close ends all the current ministerial role appointments on the same day as the government closes" do
    login_as :gds_admin
    @government.update(end_date: 1.day.ago.to_date)
    ministerial = create(:ministerial_role_appointment)
    ambassadorial = create(:ambassador_role_appointment)

    post :close, params: { id: @government.id }

    assert_equal @government.end_date, ministerial.reload.ended_at
    assert_nil ambassadorial.ended_at
    assert ambassadorial.current?
  end
end
