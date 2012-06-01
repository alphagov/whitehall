require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  def stub_record(type, options = {})
    result = build(type, options)
    result.stubs(:id).returns(next_id)
    result.stubs(:new_record?).returns(false)
    result.stubs(:to_param).returns(result.id.to_s)
    result
  end

  def next_id
    @next_id ||= 0
    @next_id += 1
  end

  setup do
    @person = stub_record(:person)
    Person.stubs(:find).returns(@person)
  end

  test "show displays name and biography" do
    @person.stubs(:name).returns("Alan Clark MP")
    @person.stubs(:biography).returns("Conservative diarist and philanderer")

    get :show, id: @person

    assert_select ".name", text: "Alan Clark MP"
    assert_select ".biography", text: "Conservative diarist and philanderer"
  end

  test "show lists current roles held by person" do
    first_appointment = stub_record(:role_appointment, role: stub_record(:ministerial_role))
    second_appointment = stub_record(:role_appointment, role: stub_record(:ministerial_role))
    @person.stubs(:current_role_appointments).returns([first_appointment, second_appointment])

    get :show, id: @person

    assert_select ".current-roles" do
      assert_select_object first_appointment do
        assert_select "a[href=#{ministerial_role_url(first_appointment.role)}]", text: first_appointment.role.name
      end
      assert_select_object second_appointment do
        assert_select "a[href=#{ministerial_role_url(second_appointment.role)}]", text: second_appointment.role.name
      end
    end
  end

  test "show doesn't include current roles section if no roles currently held" do
    @person.stubs(:current_roles).returns([])

    get :show, id: @person

    assert_select ".current-roles", count: 0
  end

  test "show lists previous roles held by person" do
    first_appointment = stub_record(:role_appointment, role: stub_record(:ministerial_role))
    second_appointment = stub_record(:role_appointment, role: stub_record(:ministerial_role))
    @person.stubs(:previous_role_appointments).returns([first_appointment, second_appointment])

    get :show, id: @person

    assert_select ".previous-roles" do
      assert_select_object first_appointment do
        assert_select "a[href=#{ministerial_role_url(first_appointment.role)}]", text: first_appointment.role.name
      end
      assert_select_object second_appointment do
        assert_select "a[href=#{ministerial_role_url(second_appointment.role)}]", text: second_appointment.role.name
      end
    end
  end

  test "show doesn't include previous roles section if no roles currently held" do
    @person.stubs(:previous_role_appointments).returns([])

    get :show, id: @person

    assert_select ".previous-roles", count: 0
  end

  test "index displays a rudimentary index of people (for url hackers)" do
    people = [@person, stub_record(:person), stub_record(:person)]
    Person.stubs(:all).returns(people)

    get :index

    assert_select ".people" do
      people.each do |person|
        assert_select_object person do
          assert_select "a[href=#{person_url(person)}]"
        end
      end
    end
  end
end