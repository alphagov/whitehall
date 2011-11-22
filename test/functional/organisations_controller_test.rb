require "test_helper"

class OrganisationsControllerTest < ActionController::TestCase
  test "shows organisation title" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select ".organisation .name", text: organisation.name
  end

  test "presents the contact details of the organisation using hcard" do
    organisation = create(:organisation, name: "Ministry of Pomp", email: "pomp@gov.uk",
                          address: "1 Smashing Place, London", postcode: "LO1 8DN",
                          phone_numbers_attributes: [
                            {description: "Helpline", number: "02079460000"},
                            {description: "Fax", number: "02079460001"}
                          ])
    get :show, id: organisation

    assert_select ".organisation.hcard" do
      assert_select ".fn.org", "Ministry of Pomp"
      assert_select ".adr" do
        assert_select ".street-address", "1 Smashing Place, London"
        assert_select ".postal-code", "LO1 8DN"
      end
      assert_select ".tel", /02079460000$/ do
        assert_select ".type", "Helpline"
      end
      assert_select ".email", organisation.email
    end
  end

  test "shows only published policies associated with organisation" do
    published_document = create(:published_policy)
    draft_document = create(:draft_policy)
    organisation = create(:organisation, documents: [published_document, draft_document])
    get :show, id: organisation
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
  end

  test "shows only published publications associated with organisation" do
    published_document = create(:published_publication)
    draft_document = create(:draft_publication)
    organisation = create(:organisation, documents: [published_document, draft_document])
    get :show, id: organisation
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
  end

  test "shows only published news articles associated with organisation" do
    published_document = create(:published_news_article)
    draft_document = create(:draft_news_article)
    organisation = create(:organisation, documents: [published_document, draft_document])
    get :show, id: organisation
    assert_select_object(published_document)
    assert_select_object(draft_document, count: 0)
  end

  test "should not display an empty published policies section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#policies", count: 0
  end

  test "should not display an empty published publications section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#publications", count: 0
  end

  test "should not display an empty published news articles section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#news_articles", count: 0
  end

  test "shows names and roles of those ministers associated with organisation" do
    person_1 = create(:person, name: "Fred")
    person_2 = create(:person, name: "Bob")
    ministerial_role_1 = create(:ministerial_role, name: "Secretary of State")
    ministerial_role_2 = create(:ministerial_role, name: "Minister of State")
    create(:role_appointment, person: person_1, role: ministerial_role_1)
    create(:role_appointment, person: person_2, role: ministerial_role_2)
    organisation = create(:organisation, ministerial_roles: [ministerial_role_1, ministerial_role_2])
    minister_in_another_organisation = create(:ministerial_role)

    get :show, id: organisation

    assert_select_object(ministerial_role_1) do
      assert_select ".current_appointee", "Fred"
      assert_select "a[href=#{ministerial_role_path(ministerial_role_1)}]", text: "Secretary of State"
    end
    assert_select_object(ministerial_role_2) do
      assert_select ".current_appointee", "Bob"
      assert_select "a[href=#{ministerial_role_path(ministerial_role_2)}]", text: "Minister of State"
    end
    assert_select_object(minister_in_another_organisation, count: 0)
  end

  test "shows minister role even if it is not currently fulfilled by any person" do
    minister = create(:ministerial_role, people: [])
    organisation = create(:organisation, ministerial_roles: [minister])

    get :show, id: organisation

    assert_select_object(minister)
  end

  test "should not display an empty ministers section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#ministers", count: 0
  end

  test "shows leading board members associated with organisation" do
    permanent_secretary = create(:board_member_role, leader: true)
    organisation = create(:organisation, board_member_roles: [permanent_secretary])

    get :show, id: organisation

    assert_select "#leading_board_members" do
      assert_select_object(permanent_secretary)
    end
  end

  test "should not display an empty leading board members section" do
    junior = create(:board_member_role)
    organisation = create(:organisation, board_member_roles: [junior])

    get :show, id: organisation

    assert_select "#leading_board_members", count: 0
  end

  test "shows board members associated with organisation" do
    permanent_secretary = create(:board_member_role)
    organisation = create(:organisation, board_member_roles: [permanent_secretary])

    get :show, id: organisation

    assert_select "#other_board_members" do
      assert_select_object(permanent_secretary)
    end
  end

  test "should not display an empty board members section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#other_board_members", count: 0
  end

  test "should link to the child organisations" do
    parent_organisation = create(:organisation)
    child_organisation = create(:organisation, parent_organisations: [parent_organisation])
    get :show, id: parent_organisation
    assert_select "#child_organisations a[href='#{organisation_path(child_organisation)}']"
  end

  test "should not display the child organisations section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#child_organisations", false
  end

  test "should link to the parent organisations" do
    parent_organisation = create(:organisation)
    child_organisation = create(:organisation, parent_organisations: [parent_organisation])
    get :show, id: child_organisation
    assert_select "#parent_organisations a[href='#{organisation_path(parent_organisation)}']"
  end

  test "should not display the parent organisations section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#parent_organisations", false
  end

  test "should link to a google map" do
    organisation = create(:organisation, latitude: 51.498772, longitude: -0.130974)
    get :show, id: organisation
    assert_select "a[href='http://maps.google.co.uk/maps?q=51.498772,-0.130974']"
  end

  test "should display the minister's picture if available" do
    ministerial_role = create(:ministerial_role)
    person = create(:person, image: File.open(File.join(Rails.root, 'test', 'fixtures', 'minister-of-funk.jpg')))
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create(:organisation, ministerial_roles: [ministerial_role])
    get :show, id: organisation
    assert_select "img[src*=minister-of-funk.jpg]"
  end

  test "should display a generic image if the minister doesn't have their own picture" do
    ministerial_role = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create(:organisation, ministerial_roles: [ministerial_role])
    get :show, id: organisation
    assert_select "img[src*=blank-person.jpg]"
  end

  test "should display a list of organisations" do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)

    get :index

    assert_select_object(organisation_1)
    assert_select_object(organisation_2)
  end

  test "should display orgsanisations in alphabetical order" do
    organisation_c = create(:organisation, name: 'C')
    organisation_a = create(:organisation, name: 'A')
    organisation_b = create(:organisation, name: 'B')

    get :index

    assert_equal [organisation_a, organisation_b, organisation_c], assigns[:organisations]
  end

end