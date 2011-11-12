require 'test_helper'

class Admin::PeopleControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test_controller_is_a Admin::BaseController

  test "creating without a name shows errors" do
    post :create, person: {name: ""}

    assert_select ".form-errors"
  end

  test "creating with valid data redirects to the index" do
    post :create, person: attributes_for(:person)

    assert_redirected_to admin_people_path
  end

  test "updating without a name shows errors" do
    person = create(:person)

    put :update, id: person.id, person: {name: ""}

    assert_select ".form-errors"
  end

  test "updating with valid data redirects to the index" do
    person = create(:person)

    put :update, id: person.id, person: attributes_for(:person)

    assert_redirected_to admin_people_path
  end

  test "should be able to destroy a destroyable person" do
    person = create(:person, name: "Dave")
    delete :destroy, id: person.id

    assert_response :redirect
    assert_equal %{"Dave" destroyed.}, flash[:notice]
  end

  test "destroying a person which has an appointment" do
    person = create(:person)
    create(:role_appointment, person: person)

    delete :destroy, id: person.id
    assert_equal "Cannot destroy a person with appointments", flash[:alert]
  end

  test "lists people by ordered name" do
    person_b = create(:person, name: "B")
    person_a = create(:person, name: "A")
    person_c = create(:person, name: "C")

    get :index

    assert_select ".people tr.person:nth-of-type(1)", text: "A"
    assert_select ".people tr.person:nth-of-type(2)", text: "B"
    assert_select ".people tr.person:nth-of-type(3)", text: "C"
  end

  test "provides delete buttons for destroyable people" do
    destroyable_person = create(:person)
    role_appointment = create(:role_appointment)
    indestructable_person = create(:person, role_appointments: [role_appointment])

    get :index

    assert_select_object destroyable_person do
      assert_select ".delete form[action='#{admin_person_path(destroyable_person)}']" do
        assert_select "input[name='_method'][value='delete']"
        assert_select "input[type='submit']"
      end
    end
    assert_select_object indestructable_person do
      assert_select ".delete form[action='#{admin_person_path(indestructable_person)}']", count: 0
    end
  end
end