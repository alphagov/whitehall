require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  disable_database_queries

  should_be_a_public_facing_controller

  def stub_role_appointment(role_type, options = {})
    organisation = stub_translatable_record(:organisation, organisation_type: OrganisationType.ministerial_department)
    stub_record(:role_appointment,
      {
        role: stub_translatable_record(role_type, organisations: [organisation]),
        person: stub_translatable_record(:person, organisations: [organisation])
      }.merge(options)
    )
  end

  setup do
    @person = stub_translatable_record(:person)
    @person.stubs(:current_role_appointments).returns([])
    @person.stubs(:organisations).returns([])
    @person.stubs(:previous_role_appointments).returns([])
    @person.stubs(:current_ministerial_roles).returns([])
    @person.stubs(:published_speeches).returns(stub("all published speeches", limit: []))
    @person.stubs(:published_news_articles).returns(stub("all published news_articles", limit: []))
    Person.stubs(:find).with(@person.to_param).returns(@person)
  end

  view_test "show displays name and biography" do
    @person.stubs(:name).returns("Alan Clark MP")
    @person.stubs(:biography).returns("Conservative diarist and philanderer")

    get :show, id: @person

    assert_select "h1", text: "Alan Clark MP"
    assert_select ".biography", text: /Conservative diarist and philanderer/
  end

  view_test "show displays image of the person" do
    @person.stubs(:image_url).returns("/path/to/person-image.png")

    get :show, id: @person

    assert_select "figure img[src='/path/to/person-image.png']"
  end

  view_test "show lists current roles held by person" do
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

  view_test "show lists previous roles held by person" do
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

  view_test "policy link hidden from in-page navigation if person has no policy" do
    get :show, id: @person

    refute_select ".in-page-navigation", text: "Policy"
  end

  def person_has_published_policy!
    @organisation = stub_record(:organisation, organisation_type: OrganisationType.ministerial_department)
    @policy = stub_edition(:published_policy, alternative_format_provider_id: next_record_id, organisations: [@organisation])
    @role = stub_record(:ministerial_role, organisations: [@organisation])
    @role.stubs(:published_policies).returns([@policy])
    @person.stubs(:current_ministerial_roles).returns([@role])
  end

  view_test "policy link shown if person has policy associated with ministerial role" do
    person_has_published_policy!

    get :show, id: @person

    assert_select ".in-page-navigation li a", text: "Policies"
  end

  view_test "policy shown if person has policy associated with ministerial role" do
    person_has_published_policy!

    get :show, id: @person

    assert_select "#policy" do
      assert_select_object @policy
    end
  end

  view_test "show doesn't include previous roles section if no roles currently held" do
    @person.stubs(:previous_role_appointments).returns([])

    get :show, id: @person

    assert_select ".previous-roles", count: 0
  end

  view_test "index displays a rudimentary index of people (for url hackers)" do
    people = [@person, stub_translatable_record(:person), stub_translatable_record(:person)]
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

  view_test 'show has atom feed autodiscovery link' do
    get :show, id: @person
    assert_select_autodiscovery_link person_url(@person, format: "atom")
  end
end

class PeopleControllerAtomFeedTest < ActionController::TestCase
  tests PeopleController

  view_test "show generates an atom feed of news and speeches associated with the person" do
    person = create(:person)
    role_appointment = create(:role_appointment, person: person)
    expected_entries = [
      create(:published_news_article, role_appointments: [role_appointment], first_published_at: 1.day.ago),
      create(:published_speech, role_appointment: role_appointment, delivered_on: 2.day.ago.to_date)
    ]

    get :show, format: :atom, id: person

    assert_select_atom_feed do
      assert_select_atom_entries(expected_entries)
    end
  end
end
