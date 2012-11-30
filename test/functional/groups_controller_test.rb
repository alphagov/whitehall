require "test_helper"

class GroupsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "should display name and govspeak-ified description of group" do
    organisation = create(:organisation)
    group = create(:group,
      name: "Defence Council",
      description: "description-in-govspeak",
      organisation: organisation
    )

    govspeak_transformation_fixture "description-in-govspeak" => "description-in-html" do
      get :show, organisation_id: organisation, id: group
    end

    assert_select "h1.main", "Defence Council"
    assert_select "p.description", "description-in-html"
  end

  test "should display a list of group members" do
    person_one, person_two = create(:person), create(:person)
    organisation = create(:organisation)
    group = create(:group, organisation: organisation, members: [person_one, person_two])

    get :show, organisation_id: organisation, id: group

    assert_select "ul.group-members" do
      assert_select_object(person_one)
      assert_select_object(person_two)
    end
  end

  test "should not display an empty list of group members" do
    organisation = create(:organisation)
    group = create(:group, organisation: organisation, members: [])

    get :show, organisation_id: organisation, id: group

    refute_select "ul.group-members"
  end
end
