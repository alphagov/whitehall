require "test_helper"

class Admin::GovernmentsControllerTest < ActionController::TestCase
  setup do
    @government = FactoryBot.create(:government)
    login_as(:gds_editor)
  end

  should_be_an_admin_controller

  %i[new edit prepare_to_close].each do |action_method|
    test "GDS admin permission required to access #{action_method}" do
      get action_method, params: { id: @government.id }
      assert_response :forbidden
    end
  end

  %i[create update close].each do |action_method|
    test "GDS admin permission required to access #{action_method}" do
      post action_method, params: { id: @government.id }
      assert_response :forbidden
    end
  end

  view_test "new should have the correct form fields and default start date of today" do
    Timecop.freeze(2020, 4, 17)
    login_as :gds_admin
    get :new
    assert_select "input[name='government[name]']"
    assert_select "input[name='government[start_date(1i)]'][value='2020']"
    assert_select "input[name='government[start_date(2i)]'][value='4']"
    assert_select "input[name='government[start_date(3i)]'][value='17']"

    assert_select "input[name='government[end_date(1i)]']"
    assert_select "input[name='government[end_date(2i)]']"
    assert_select "input[name='government[end_date(3i)]']"
  end

  test "#close sets the end date to today" do
    login_as :gds_admin
    post :close, params: { id: @government.id }
    @government.reload
    assert_equal Time.zone.today, @government.end_date
  end

  test "#close doesn't overwrite an end date if there is one" do
    login_as :gds_admin
    @government.update!(end_date: 10.days.ago.to_date)
    post :close, params: { id: @government.id }
    @government.reload
    assert_equal 10.days.ago.to_date, @government.end_date
  end

  test "#close ends all the current ministerial role appointments on the same day as the government closes" do
    login_as :gds_admin
    @government.update!(end_date: 1.day.ago.to_date)
    ministerial = create(:ministerial_role_appointment)
    ambassadorial = create(:ambassador_role_appointment)

    post :close, params: { id: @government.id }

    assert_equal @government.end_date, ministerial.reload.ended_at
    assert_nil ambassadorial.ended_at
    assert ambassadorial.current?
  end

  view_test "edit renders the correct fields and prepare to close link when editing the current government" do
    login_as :gds_admin
    get :edit, params: { id: @government.id }

    assert_select "input[name='government[name]'][value='#{@government.name}']"
    assert_select "input[name='government[start_date(1i)]'][value='#{@government.start_date.year}']"
    assert_select "input[name='government[start_date(2i)]'][value='#{@government.start_date.month}']"
    assert_select "input[name='government[start_date(3i)]'][value='#{@government.start_date.day}']"
    assert_select "input[name='government[end_date(1i)]']"
    assert_select "input[name='government[end_date(2i)]']"
    assert_select "input[name='government[end_date(3i)]']"
    assert_select "a[href='#{prepare_to_close_admin_government_path(@government)}']", text: "Prepare to close this government"
  end

  view_test "edit renders the correct fields when editing a past government" do
    @government = FactoryBot.build(:government, end_date: "2011-12-13")
    @government.save!(validate: false) # fiddly making a past government that doesn't cause an 'overlap' validation error

    login_as :gds_admin
    get :edit, params: { id: @government.id }

    assert_select "input[name='government[name]'][value='#{@government.name}']"
    assert_select "input[name='government[start_date(1i)]'][value='#{@government.start_date.year}']"
    assert_select "input[name='government[start_date(2i)]'][value='#{@government.start_date.month}']"
    assert_select "input[name='government[start_date(3i)]'][value='#{@government.start_date.day}']"
    assert_select "input[name='government[end_date(1i)]'][value='2011']"
    assert_select "input[name='government[end_date(2i)]'][value='12']"
    assert_select "input[name='government[end_date(3i)]'][value='13']"
  end

  view_test "edit does not render the prepare to close link when editing a previous government" do
    @government.update!(end_date: 1.minute.ago)
    create(:government, start_date: Time.zone.now)
    login_as :gds_admin
    get :edit, params: { id: @government.id }
    assert_select "a[href='#{prepare_to_close_admin_government_path(@government)}']", text: "Prepare to close this government", count: 0
  end
end
