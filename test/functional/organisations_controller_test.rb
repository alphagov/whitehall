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

  test "shows ministers associated with organisation" do
    first_minister = create(:ministerial_role)
    second_minister = create(:ministerial_role)
    organisation = create(:organisation, ministerial_roles: [first_minister, second_minister])
    minister_in_another_organisation = create(:ministerial_role)

    get :show, id: organisation

    assert_select_object(first_minister)
    assert_select_object(second_minister)
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