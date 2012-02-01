require "test_helper"

class OrganisationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "shows organisation title and description" do
    organisation = create(:organisation,
      name: "organisation-name",
      description: "organisation-description"
    )
    get :show, id: organisation
    assert_select ".organisation .name", text: "organisation-name"
    assert_select ".description", text: "organisation-description"
  end

  test "presents the contact details of the organisation using hcard" do
    ministerial_department = create(:organisation_type, name: "Ministerial Department")
    organisation = create(:organisation, organisation_type: ministerial_department,
      name: "Ministry of Pomp", contacts_attributes: [
        {email: "pomp@gov.uk",
         address: "1 Smashing Place, London", postcode: "LO1 8DN"},
        {description: "Helpline", number: "02079460000"},
        {description: "Fax", number: "02079460001"}
      ]
    )
    get :show, id: organisation

    assert_select ".organisation.hcard" do
      assert_select ".fn.org", "Ministry of Pomp"
      assert_select ".category", "Ministerial Department"
      assert_select ".adr" do
        assert_select ".street-address", "1 Smashing Place, London"
        assert_select ".postal-code", "LO1 8DN"
      end
      assert_select ".tel", /02079460000$/ do
        assert_select ".type", "Helpline"
      end
      assert_select ".email", /pomp@gov\.uk/ do
        assert_select ".type", "Email"
      end
    end
  end

  test "should use html line breaks when displaying the address" do
    organisation = create(:organisation, contacts_attributes: [{address: "Line 1\nLine 2"}])
    get :show, id: organisation
    assert_select ".street-address", /Line 1/
    assert_select ".street-address", /Line 2/
    assert_select ".street-address br", count: 1
  end

  test "shows only published policies associated with organisation" do
    published_document = create(:published_policy)
    draft_document = create(:draft_policy)
    organisation = create(:organisation, documents: [published_document, draft_document])
    get :show, id: organisation
    assert_select_object(published_document)
    refute_select_object(draft_document)
  end

  test "shows only published publications associated with organisation" do
    published_document = create(:published_publication)
    draft_document = create(:draft_publication)
    organisation = create(:organisation, documents: [published_document, draft_document])
    get :show, id: organisation
    assert_select_object(published_document)
    refute_select_object(draft_document)
  end

  test "shows only published corporate publications associated with organisation" do
    published_corporate_publication = create(:published_corporate_publication)
    draft_corporate_publication = create(:draft_corporate_publication)
    organisation = create(:organisation, documents: [
      published_corporate_publication,
      draft_corporate_publication
    ])
    get :show, id: organisation
    assert_select_object(published_corporate_publication)
    refute_select_object(draft_corporate_publication)
  end

  test "should not display an empty published policies section" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#policies"
  end

  test "should not display an empty published publications section" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#publications"
  end

  test "shows names and roles of those ministers associated with organisation" do
    person_1 = create(:person, forename: "Fred")
    person_2 = create(:person, forename: "Bob")
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
    refute_select_object(minister_in_another_organisation)
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
    refute_select "#ministers"
  end

  test "shows leading board members associated with organisation" do
    permanent_secretary = create(:board_member_role, permanent_secretary: true)
    organisation = create(:organisation, board_member_roles: [permanent_secretary])

    get :show, id: organisation

    assert_select permanent_secretary_board_members_selector do
      assert_select_object(permanent_secretary)
    end
  end

  test "should not display an empty leading board members section" do
    junior = create(:board_member_role)
    organisation = create(:organisation, board_member_roles: [junior])

    get :show, id: organisation

    refute_select permanent_secretary_board_members_selector
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
    refute_select "#other_board_members"
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
    refute_select "#child_organisations"
  end

  test "should link to the parent organisations" do
    parent_organisation = create(:organisation)
    child_organisation = create(:organisation, parent_organisations: [parent_organisation])
    get :show, id: child_organisation
    assert_select ".meta a[href='#{organisation_path(parent_organisation)}']"
  end

  test "should not display the parent organisations section" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#parent_organisations"
  end

  test "should link to a google map" do
    organisation = create(:organisation, contacts_attributes: [{latitude: 51.498772, longitude: -0.130974}])
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
    assert_select "img[src*=blank-person.png]"
  end

  test "should display a link to the about-us page for the organisation" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select ".about a[href='#{about_organisation_path(organisation)}']"
  end

  test "should display the organisation's policy areas" do
    first_policy_area = create(:policy_area)
    second_policy_area = create(:policy_area)
    organisation = create(:organisation, policy_areas: [first_policy_area, second_policy_area])
    get :show, id: organisation
    assert_select "#policy_areas" do
      assert_select_object first_policy_area
      assert_select_object second_policy_area
    end
  end

  test "should not display an empty policy areas section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#policy_areas", count: 0
  end

  test "should display a link to the news page for the organisation" do
    organisation = create(:organisation)

    get :show, id: organisation

    assert_select ".all_news a[href='#{news_organisation_path(organisation)}']"
  end

  test "should show only published news articles associated with organisation" do
    published_news_article = create(:published_news_article)
    draft_news_article = create(:draft_news_article)
    another_published_news_article = create(:published_news_article)
    organisation = create(:organisation, documents: [published_news_article, draft_news_article])

    get :news, id: organisation

    assert_select_object(published_news_article)
    refute_select_object(draft_news_article)
    refute_select_object(another_published_news_article)
  end

  test "should show explanatory text if there are no news articles for the organisation" do
    organisation = create(:organisation, name: "Cabinet Office")

    get :news, id: organisation

    assert_select "p", "There are no Cabinet Office news articles at present."
  end

  test "should order news articles in order of publication date with most recent first" do
    earlier_news_article = create(:published_news_article, published_at: 2.days.ago)
    later_news_article = create(:published_news_article, published_at: 1.days.ago)
    organisation = create(:organisation, documents: [earlier_news_article, later_news_article])

    get :news, id: organisation

    assert_equal [later_news_article, earlier_news_article], assigns(:news_articles)
  end

  test "should display an about-us page for the organisation" do
    organisation = create(:organisation,
      name: "organisation-name",
      about_us: "organisation-about-us"
    )

    get :about, id: organisation

    assert_select ".page_title", text: "organisation-name"
    assert_select ".body", text: "organisation-about-us"
  end

  test "should render the about-us content using govspeak markup" do
    organisation = create(:organisation,
      name: "organisation-name",
      about_us: "body-in-govspeak"
    )

    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :about, id: organisation

    assert_select ".body", text: "body-in-html"
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

    get :alphabetical

    assert_equal [organisation_a, organisation_b, organisation_c], assigns[:organisations]
  end
end