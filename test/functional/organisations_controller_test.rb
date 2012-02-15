require "test_helper"

class OrganisationsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "shows organisation logo formatted name and description" do
    organisation = create(:organisation,
      logo_formatted_name: "organisation\nname is\nformatted",
      description: "organisation-description"
    )
    get :show, id: organisation
    assert_select ".organisation .name", html: "organisation<br />name is<br />formatted"
    assert_select ".description", text: "organisation-description"
  end

  test "shows 3 most recent published policies associated with organisation" do
    policies = (0..3).map { |n| create(:published_policy, published_at: n.days.ago) }
    draft_policy = create(:draft_policy)
    organisation = create(:organisation, documents: policies)
    get :show, id: organisation
    policies[0..2].each do |policy|
      assert_select_object(policy)
    end
    refute_select_object(policies[3])
    refute_select_object(draft_policy)
  end

  test "links to dedicated policies page" do
    organisation = create(:organisation, documents: [create(:published_policy)])
    get :show, id: organisation
    assert_select '#policies a[href=?]', policies_organisation_path(organisation)
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

  test "should only display the 3 most recent non-corporate publications ordered by publication date" do
    organisation = create(:organisation)
    older_publication = create(:published_publication, title: "older", publication_date: 3.days.ago, organisations: [organisation])
    newest_publication = create(:published_publication, title: "newest", publication_date: 1.day.ago, organisations: [organisation])
    oldest_publication = create(:published_publication, title: "oldest", publication_date: 4.days.ago, organisations: [organisation])
    newer_publication = create(:published_publication, title: "newer", publication_date: 2.days.ago, organisations: [organisation])

    get :show, id: organisation

    assert_select "#publications li.publication", count: 3
    assert_select "#publications li#{record_css_selector(newest_publication)}, #publications li#{record_css_selector(newer_publication)}, li#publications #{record_css_selector(older_publication)}"
  end

  test "should link to the organisation's publications page" do
    organisation = create(:organisation)
    publication = create(:published_publication, organisations: [organisation])

    get :show, id: organisation

    assert_select "#publications a[href=#{publications_organisation_path(organisation)}]"
  end

  test "shows only published consultations associated with organisation" do
    published_document = create(:published_consultation)
    draft_document = create(:draft_consultation)
    organisation = create(:organisation, documents: [published_document, draft_document])
    get :show, id: organisation
    assert_select '#consultations' do
      assert_select_object(published_document)
      refute_select_object(draft_document)
    end
  end

  test "shows only 3 most recent consultations when more exist" do
    consultations = 5.times.map do |n|
      create(:published_consultation, published_at: n.days.ago)
    end

    organisation = create(:organisation, documents: consultations)
    get :show, id: organisation
    assert_equal 3, assigns[:consultations].size
    assert_equal consultations.take(3), assigns[:consultations]
  end

  test "shows only 3 speeches with latest first_published_at when more exist" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    speeches = 5.times.map do |n|
      create(:published_speech, role_appointment: role_appointment, first_published_at: (5-n).days.ago)
    end

    get :show, id: organisation

    assert_equal 3, assigns[:speeches].size
    assert_equal speeches.reverse.take(3), assigns[:speeches]
  end

  test "should link to the organisation's news and speeches page" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    speech = create(:published_speech, role_appointment: role_appointment)

    get :show, id: organisation

    assert_select "#speeches a[href=#{announcements_organisation_path(organisation)}]"
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

  test "should not display an empty consultations section" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#consultations"
  end

  test "should link to the active child organisations" do
    parent_organisation = create(:organisation)
    child_organisation = create(:organisation, parent_organisations: [parent_organisation], active: true)
    get :show, id: parent_organisation
    assert_select "#child_organisations a[href='#{organisation_path(child_organisation)}']"
  end

  test "should just list but not link to inactive child organisations" do
    parent_organisation = create(:organisation)
    child_organisation = create(:organisation, parent_organisations: [parent_organisation], active: false)
    get :show, id: parent_organisation
    refute_select "#child_organisations a[href='#{organisation_path(child_organisation)}']"
    assert_select "#child_organisations li", text: child_organisation.name
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

  test "should display a link to the about-us page for the organisation" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select ".sub_navigation a[href='#{about_organisation_path(organisation)}']"
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

  test "should display a link to the announcements page for the organisation" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "nav a[href='#{announcements_organisation_path(organisation)}']"
  end

  test "presents the contact details of the organisation using hcard" do
    ministerial_department = create(:organisation_type, name: "Ministerial Department")
    organisation = create(:organisation, organisation_type: ministerial_department,
      name: "Ministry of Pomp", contacts_attributes: [{
        description: "Main",
        email: "pomp@gov.uk",
        address: "1 Smashing Place, London", postcode: "LO1 8DN",
        contact_numbers_attributes: [
          { label: "Helpline", number: "02079460000" },
          { label: "Fax", number: "02079460001" }
        ]
      }]
    )
    get :contact_details, id: organisation

    assert_select ".organisation.hcard" do
      assert_select ".fn.org", "Ministry of Pomp"
      assert_select ".category", "Ministerial Department"
      assert_select ".adr" do
        assert_select ".street-address", "1 Smashing Place, London"
        assert_select ".postal-code", "LO1 8DN"
      end
      assert_select ".tel", /02079460000/ do
        assert_select ".type", "Helpline"
      end
      assert_select ".email", /pomp@gov\.uk/ do
        assert_select ".type", "Email"
      end
    end
  end

  test "should use html line breaks when displaying the address" do
    organisation = create(:organisation, contacts_attributes: [{description: "Main", address: "Line 1\nLine 2"}])
    get :contact_details, id: organisation
    assert_select ".street-address", /Line 1/
    assert_select ".street-address", /Line 2/
    assert_select ".street-address br", count: 1
  end

  test "should link to a google map" do
    organisation = create(:organisation, contacts_attributes: [{description: "Main", latitude: 51.498772, longitude: -0.130974}])
    get :contact_details, id: organisation
    assert_select "a[href='http://maps.google.co.uk/maps?q=51.498772,-0.130974']"
  end

  test "should show only published news articles associated with organisation" do
    published_news_article = create(:published_news_article)
    draft_news_article = create(:draft_news_article)
    another_published_news_article = create(:published_news_article)
    organisation = create(:organisation, documents: [published_news_article, draft_news_article])

    get :announcements, id: organisation

    assert_select_object(published_news_article)
    refute_select_object(draft_news_article)
    refute_select_object(another_published_news_article)
  end

  test "should show only published speeches associated with organisation" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    published_speech = create(:published_speech, role_appointment: role_appointment)
    draft_speech = create(:draft_speech, role_appointment: role_appointment)
    another_published_speech = create(:published_speech)

    get :announcements, id: organisation

    assert_select_object(published_speech)
    refute_select_object(draft_speech)
    refute_select_object(another_published_speech)
  end

  test "should order news articles and speeches in order of first publication date with most recent first" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    earlier_news_article = create(:published_news_article, first_published_at: 4.days.ago, organisations: [organisation])
    later_speech = create(:published_speech, first_published_at: 3.days.ago, role_appointment: role_appointment)

    get :announcements, id: organisation

    assert_equal [later_speech, earlier_news_article], assigns(:announcements)
  end

  test "should show published consultations associated with the organisation" do
    published_consultation = create(:published_consultation)
    draft_consultation = create(:draft_consultation)
    organisation = create(:organisation, documents: [published_consultation, draft_consultation])

    get :consultations, id: organisation

    assert_select_object(published_consultation)
    refute_select_object(draft_consultation)
  end

  test "should show consultations in order of publication date" do
    earlier_consultation = create(:published_consultation, published_at: 2.days.ago)
    later_consultation = create(:published_consultation, published_at: 1.days.ago)
    organisation = create(:organisation, documents: [earlier_consultation, later_consultation])

    get :consultations, id: organisation

    assert_equal [later_consultation, earlier_consultation], assigns(:consultations)
  end

  test "should display all published corporate and non-corporate publications for the organisation" do
    organisation = create(:organisation)
    published_publication = create(:published_publication, organisations: [organisation])
    draft_publication = create(:draft_publication, organisations: [organisation])
    published_corporate_publication = create(:published_corporate_publication, organisations: [organisation])

    get :publications, id: organisation

    assert_equal [published_publication, published_corporate_publication].to_set, assigns(:publications).to_set
  end

  test "should order publications by publication date" do
    organisation = create(:organisation)
    older_publication = create(:published_publication, title: "older", publication_date: 3.days.ago, organisations: [organisation])
    newest_publication = create(:published_publication, title: "newest", publication_date: 1.day.ago, organisations: [organisation])
    oldest_publication = create(:published_publication, title: "oldest", publication_date: 4.days.ago, organisations: [organisation])

    get :publications, id: organisation

    assert_select "#publications .row" do
      assert_select "div:nth-child(1) #{record_css_selector(newest_publication)}"
      assert_select "div:nth-child(2) #{record_css_selector(older_publication)}"
      assert_select "div:nth-child(3) #{record_css_selector(oldest_publication)}"
    end
  end

  test "should display an about-us page for the organisation" do
    organisation = create(:organisation,
      logo_formatted_name: "organisation\nlogo name\nis formatted",
      about_us: "organisation-about-us"
    )

    get :about, id: organisation

    assert_select ".page_title", html: "organisation<br />logo name<br />is formatted"
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

  test "should display corporate publications on about-us page" do
    published_corporate_publication = create(:published_corporate_publication)
    organisation = create(:organisation, documents: [
      published_corporate_publication,
    ])
    get :about, id: organisation
    assert_select_object(published_corporate_publication)
  end

  test "shows ministerial roles in the specified order" do
    junior_role = create(:ministerial_role)
    senior_role = create(:ministerial_role)
    organisation = create(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :ministers, id: organisation

    assert_equal [senior_role, junior_role], assigns(:ministerial_roles)
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

    get :ministers, id: organisation

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

    get :ministers, id: organisation

    assert_select_object(minister)
  end

  test "should display the minister's picture if available" do
    ministerial_role = create(:ministerial_role)
    person = create(:person, image: File.open(File.join(Rails.root, 'test', 'fixtures', 'minister-of-funk.jpg')))
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create(:organisation, ministerial_roles: [ministerial_role])
    get :ministers, id: organisation
    assert_select "img[src*=minister-of-funk.jpg]"
  end

  test "should display a generic image if the minister doesn't have their own picture" do
    ministerial_role = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create(:organisation, ministerial_roles: [ministerial_role])
    get :ministers, id: organisation
    assert_select "img[src*=blank-person.png]"
  end

  test "shows management team associated with organisation" do
    permanent_secretary = create(:board_member_role)
    organisation = create(:organisation, board_member_roles: [permanent_secretary])

    get :management_team, id: organisation

    assert_select "#other_board_members" do
      assert_select_object(permanent_secretary)
    end
  end

  test "shows leading management team members associated with organisation" do
    permanent_secretary = create(:board_member_role, permanent_secretary: true)
    organisation = create(:organisation, board_member_roles: [permanent_secretary])

    get :management_team, id: organisation

    assert_select permanent_secretary_board_members_selector do
      assert_select_object(permanent_secretary)
    end
  end

  test "should not display an empty leading management team section" do
    junior = create(:board_member_role)
    organisation = create(:organisation, board_member_roles: [junior])

    get :management_team, id: organisation

    refute_select permanent_secretary_board_members_selector
  end

  test "should not display an empty management team section" do
    organisation = create(:organisation)
    get :management_team, id: organisation
    refute_select "#other_board_members"
  end

  test "should link to the organisation's ministers page" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    speech = create(:published_speech, role_appointment: role_appointment)

    get :show, id: organisation

    assert_select '#ministers a[href=?]', ministers_organisation_path(organisation)
  end

  test "shows only published policies associated with organisation on policies page" do
    published_policy = create(:published_policy)
    draft_policy = create(:draft_policy)
    unrelated_policy = create(:published_policy)
    organisation = create(:organisation, documents: [published_policy, draft_policy])

    get :policies, id: organisation

    assert_select_object(published_policy)
    refute_select_object(draft_policy)
    refute_select_object(unrelated_policy)
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

  test "should place organisation specific css class on every organisation sub page" do
    organisation = create(:organisation)

    [:show, :about, :consultations, :contact_details, :management_team, :ministers, :policies, :publications].each do |page|
      get page, id: organisation
      assert_select "##{dom_id(organisation)}.#{organisation.slug}"
    end
  end
end
