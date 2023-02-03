require "test_helper"

class HistoricAppointmentsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "routing for :show action" do
    assert_routing(
      { path: "government/history/past-prime-ministers/barry", method: :get },
      controller: "historic_appointments",
      action: "show",
      id: "barry",
    )
  end

  test "GET on :show loads the person, appointment and historical account for previous Prime Ministers" do
    person = create(:person)
    create(:historic_role_appointment, person:, role: pm_role)
    pm_account = create(:historical_account, person:, roles: [pm_role])

    get :show, params: { role: "past-prime-ministers", id: pm_account.person.slug }

    assert_response :success
    assert_template :show
    assert_equal pm_role, assigns(:role)
    assert_equal pm_account, assigns(:historical_account)
    assert_equal PersonPresenter.new(pm_account.person, @controller.view_context), assigns(:person)
  end

  test "GET on :show raises a 404 if a person does not exist with a historical account in the specified role" do
    chancellor_account = create(:historical_account, roles: [chancellor_role])

    assert_raise ActiveRecord::RecordNotFound do
      get :show, params: { role: "past-prime-ministers", id: chancellor_account.person.slug }
    end
  end

private

  def pm_role
    @pm_role ||= create(:prime_minister_role)
  end

  def chancellor_role
    @chancellor_role ||= create(:historic_role, name: "Chancellor of the Exchequer", slug: "chancellor-of-the-exchequer")
  end

  def assert_equal_role_presenters(role_appointments, expected)
    assert_equal(role_appointments, expected.map(&:to_model))
  end
end
