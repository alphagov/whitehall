require "test_helper"

class HistoricAppointmentsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "routing for static chancellors page" do
    assert_routing(
      { path: "government/history/past-chancellors", method: :get },
      controller: "historic_appointments",
      action: "past_chancellors",
    )
  end

  test "routing for :show action" do
    assert_routing(
      { path: "government/history/past-prime-ministers/barry", method: :get },
      controller: "historic_appointments",
      action: "show",
      role: "past-prime-ministers",
      person_id: "barry",
    )
  end

  test "GET on :index loads the past appointments for the role and renders the index template" do
    previous_pm1 = create(:ministerial_role_appointment, role: pm_role, started_at: 8.years.ago, ended_at: 4.years.ago)
    previous_pm2 = create(:ministerial_role_appointment, role: pm_role, started_at: 4.years.ago, ended_at: 1.day.ago)
    _current_pm = create(:ministerial_role_appointment, role: pm_role, started_at: Time.zone.now)
    eighteenth_and_nineteenth_century_appointments = create(:ministerial_role_appointment, role: pm_role, started_at: Date.civil(1701), ended_at: Date.civil(1900))

    create(:historical_account, roles: [chancellor_role])
    get :index, params: { role: "past-prime-ministers" }

    assert_response :success
    assert_template :index
    assert_equal pm_role, assigns(:role)

    assert_equal_role_presenters [previous_pm2, previous_pm1], assigns(:recent_appointments)
    assert_equal_role_presenters [eighteenth_and_nineteenth_century_appointments], assigns(:eighteenth_and_nineteenth_century_appointments)
  end

  test "GET on :past_chancellors renders the template" do
    get :past_chancellors

    assert_response :success
    assert_template :past_chancellors
  end

  test "GET on :show loads the person, appointment and historical account for previous Prime Ministers" do
    pm_account = create(:historical_account, roles: [pm_role])
    create(:role_appointment, person: pm_account.person, role: pm_role)
    get :show, params: { role: "past-prime-ministers", person_id: pm_account.person.slug }

    assert_response :success
    assert_template :show
    assert_equal pm_role, assigns(:role)
    assert_equal pm_account, assigns(:historical_account)
    assert_equal PersonPresenter.new(pm_account.person, @controller.view_context), assigns(:person)
  end

  test "GET on :show loads the person, appointment and historical account for previous Chanellors" do
    chancellor_account = create(:historical_account, roles: [chancellor_role])
    create(:role_appointment, person: chancellor_account.person, role: chancellor_role)
    get :show, params: { role: "past-chancellors", person_id: chancellor_account.person.slug }

    assert_response :success
    assert_template :show
    assert_equal chancellor_role, assigns(:role)
    assert_equal chancellor_account, assigns(:historical_account)
    assert_equal PersonPresenter.new(chancellor_account.person, @controller.view_context), assigns(:person)
  end

  test "GET on :show raises a 404 if a person does not exist with a historical account in the specified role" do
    chancellor_account = create(:historical_account, roles: [chancellor_role])

    assert_raise ActiveRecord::RecordNotFound do
      get :show, params: { role: "past-prime-ministers", person_id: chancellor_account.person.slug }
    end
  end

private

  def pm_role
    @pm_role ||= create(:historic_role, name: "Prime Minister", slug: "prime-minister")
  end

  def chancellor_role
    @chancellor_role ||= create(:historic_role, name: "Chancellor of the Exchequer", slug: "chancellor-of-the-exchequer")
  end

  def assert_equal_role_presenters(role_appointments, expected)
    assert_equal(role_appointments, expected.map(&:to_model))
  end
end
