require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  disable_database_queries

  should_be_a_public_facing_controller

  def stub_role_appointment(role_type, options = {})
    stub_record(:role_appointment, 
      {
        role: stub_record(role_type, organisations: []), 
        person: stub_record(:person, organisations: [])
      }.merge(options)
    )
  end

  setup do
    @person = stub_record(:person)
    @person.stubs(:current_role_appointments).returns([])
    @person.stubs(:previous_role_appointments).returns([])
    @person.stubs(:current_ministerial_roles).returns([])
    @person.stubs(:published_speeches).returns(stub("all published speeches", limit: []))
    @person.stubs(:published_news_articles).returns(stub("all published news_articles", limit: []))
    Person.stubs(:find).with(@person.to_param).returns(@person)
  end

  test "show displays name and biography" do
    @person.stubs(:name).returns("Alan Clark MP")
    @person.stubs(:biography).returns("Conservative diarist and philanderer")

    get :show, id: @person

    assert_select ".name", text: "Alan Clark MP"
    assert_select ".biography", text: /Conservative diarist and philanderer/
  end

  test "show displays image of the person" do
    @person.stubs(:image_url).returns("/path/to/person-image.png")

    get :show, id: @person

    assert_select "figure img[src='/path/to/person-image.png']"
  end

  test "show lists current roles held by person" do
    first_appointment = stub_role_appointment(:ministerial_role)
    second_appointment = stub_role_appointment(:ministerial_role)
    @person.stubs(:current_role_appointments).returns([first_appointment, second_appointment])

    get :show, id: @person

    assert_select ".current-roles" do
      assert_select_object first_appointment do
        assert_select "a[href=#{ministerial_role_path(first_appointment.role)}]"
      end
      assert_select_object second_appointment do
        assert_select "a[href=#{ministerial_role_path(second_appointment.role)}]"
      end
    end
  end

  test "show lists previous roles held by person" do
    first_appointment = stub_role_appointment(:ministerial_role)
    second_appointment = stub_role_appointment(:ministerial_role)
    @person.stubs(:previous_role_appointments).returns([first_appointment, second_appointment])

    get :show, id: @person

    assert_select ".previous-roles" do
      assert_select_object first_appointment do
        assert_select "a[href=#{ministerial_role_path(first_appointment.role)}]", text: first_appointment.role.name
      end
      assert_select_object second_appointment do
        assert_select "a[href=#{ministerial_role_path(second_appointment.role)}]", text: second_appointment.role.name
      end
    end
  end

  test "policy link hidden from in-page navigation if person has no policy" do
    get :show, id: @person

    refute_select ".in-page-navigation", text: "Policy"
  end

  def person_has_published_policy!
    @policy = stub_record(:published_policy, document: stub_record(:document), alternative_format_provider_id: next_record_id)
    @role = stub_record(:ministerial_role)
    @role.stubs(:published_policies).returns([@policy])
    @person.stubs(:current_ministerial_roles).returns([@role])
  end    

  test "policy link shown if person has policy associated with ministerial role" do
    person_has_published_policy!

    get :show, id: @person

    assert_select ".in-page-navigation li a", text: "Policy"
  end

  test "policy shown if person has policy associated with ministerial role" do
    person_has_published_policy!

    get :show, id: @person

    assert_select "#policy" do
      assert_select_object @policy
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
          assert_select "a[href=#{person_path(person)}]"
        end
      end
    end
  end
end
