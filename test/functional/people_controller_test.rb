require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  include FeedHelper

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
    @person = create(:person)
  end

  view_test "#show displays the details of the person and their roles" do
    first_appointment = create(:ministerial_role_appointment, person: @person)
    second_appointment = create(:ministerial_role_appointment, person: @person)
    get :show, id: @person

    assert_select "h1", text: @person.name
    assert_select ".biography", text: @person.biography

    assert_select ".current-roles" do
      assert_select_object first_appointment do
        assert_select "a[href=#{ministerial_role_path(first_appointment.role)}]"
      end
      assert_select_object second_appointment do
        assert_select "a[href=#{ministerial_role_path(second_appointment.role)}]"
      end
    end
  end

  view_test "#show lists policies associated with the person's ministerial role" do
    appointment = create(:ministerial_role_appointment, person: @person)
    policy = create(:published_policy, ministerial_roles: [appointment.role])

    get :show, id: @person

    assert_select "#policy" do
      assert_select_object policy
    end
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
    assert_select_autodiscovery_link atom_feed_url_for(@person)
  end

  view_test "#show generates an atom feed of news and speeches associated with the person" do
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
