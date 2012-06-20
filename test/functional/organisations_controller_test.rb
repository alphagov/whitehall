require "test_helper"

class OrganisationsControllerTest < ActionController::TestCase

  SUBPAGE_ACTIONS = [:about, :agencies_and_partners, :announcements, :consultations, :contact_details, :management_team, :ministers, :policies, :publications]

  should_be_a_public_facing_controller

  test "should display the disclaimer on active organisations" do
    organisation = create(:organisation, active: true, url: "url-of-main-website-for-organisation")
    get :show, id: organisation
    assert_disclaimer_present(organisation)
  end

  test "should display the disclaimer on inactive organisations" do
    organisation = create(:organisation, active: false, url: "url-of-main-website-for-organisation")
    get :show, id: organisation
    assert_disclaimer_present(organisation)
  end

  test "shows organisation name and description" do
    organisation = create(:organisation,
      name: "unformatted name",
      description: "organisation-description"
    )
    get :show, id: organisation
    assert_select ".organisation .name", text: "unformatted name"
    assert_select ".organisation .description", text: "organisation-description"
  end

  test "show links to the top civil servant" do
    permanent_secretary = create(:board_member_role, permanent_secretary: true)
    person = create(:person)
    create(:role_appointment, role: permanent_secretary, person: person)
    organisation = create(:organisation, board_member_roles: [permanent_secretary])

    get :show, id: organisation

    assert_select_object permanent_secretary do
      assert_select "a[href=?]", person_url(person), text: person.name
    end
  end

  test "show links to the top minister" do
    cabinet_minister = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, role: cabinet_minister, person: person)
    organisation = create(:organisation, ministerial_roles: [cabinet_minister])

    get :show, id: organisation

    assert_select_object cabinet_minister do
      assert_select "a[href=?]", person_url(person), text: person.name
    end
  end

  test "#show doesn't present expanded navigation for non-department organisations" do
    organisation = create(:organisation, organisation_type: create(:organisation_type, name: "Other"))
    get :show, id: organisation
    assert_select "nav" do
      refute_select "a[href=?]", announcements_organisation_path(organisation)
      refute_select "a[href=?]", policies_organisation_path(organisation)
      refute_select "a[href=?]", publications_organisation_path(organisation)
      refute_select "a[href=?]", consultations_organisation_path(organisation)
      refute_select "a[href=?]", ministers_organisation_path(organisation)
    end
  end

  test "shows featured editions in order of first publication date with most recent first" do
    organisation = create(:organisation)
    less_recent_news_article = create(:published_news_article, first_published_at: 2.days.ago)
    more_recent_policy = create(:published_policy, first_published_at: 1.day.ago)
    create(:edition_organisation, edition: less_recent_news_article, organisation: organisation, featured: true)
    create(:edition_organisation, edition: more_recent_policy, organisation: organisation, featured: true)

    get :show, id: organisation

    assert_equal [more_recent_policy, less_recent_news_article], assigns(:featured_editions)
  end

  test "shows a maximum of 3 featured editions" do
    organisation = create(:organisation)
    4.times do
      edition = create(:published_edition)
      create(:edition_organisation, edition: edition, organisation: organisation, featured: true)
    end

    get :show, id: organisation

    assert_equal 3, assigns(:featured_editions).length
  end

  test "shows organisation's featured news article with image" do
    lead_image = create(:image)
    news_article = create(:published_news_article, images: [lead_image])
    organisation = create(:organisation)
    create(:edition_organisation, edition: news_article, organisation: organisation, featured: true)

    get :show, id: organisation

    assert_select_object news_article do
      assert_select ".img img[src$='#{lead_image.url}']"
    end
  end

  test "shows organisation's featured news article with a blank image where no image has been supplied" do
    news_article = create(:published_news_article)
    organisation = create(:organisation)
    create(:edition_organisation, edition: news_article, organisation: organisation, featured: true)

    get :show, id: organisation

    assert_select_object news_article do
      assert_select ".img img[src$='generic_image.jpg']"
    end
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

  # TODO: this section is moving to a separate view
  # test "should link to the active child organisations" do
  #   parent_organisation = create(:organisation)
  #   child_organisation = create(:organisation, parent_organisations: [parent_organisation], active: true)
  #   get :show, id: parent_organisation
  #   assert_select "#child_organisations a[href='#{organisation_path(child_organisation)}']"
  # end

  # test "should just list but not link to inactive child organisations" do
  #   parent_organisation = create(:organisation)
  #   child_organisation = create(:organisation, parent_organisations: [parent_organisation], active: false)
  #   get :show, id: parent_organisation
  #   refute_select "#child_organisations a[href='#{organisation_path(child_organisation)}']"
  #   assert_select "#child_organisations li", text: child_organisation.name
  # end

  test "should not display the child organisations section" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#child_organisations"
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

  test "should display the organisation's topics with content" do
    topics = [0, 1, 2].map { |n| create(:topic, published_edition_count: n) }
    organisation = create(:organisation, topics: topics)
    get :show, id: organisation
    assert_select "#topics" do
      assert_select_object topics[1]
      assert_select_object topics[2]
      refute_select_object topics[0]
    end
  end

  test "should not display an empty topics section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#topics", count: 0
  end

  test "should display a link to the announcements page for department organisations" do
    organisation = create(:ministerial_department)
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
    organisation = create(:organisation, editions: [published_news_article, draft_news_article])

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
    organisation = create(:organisation, editions: [published_consultation, draft_consultation])

    get :consultations, id: organisation

    assert_select_object(published_consultation)
    refute_select_object(draft_consultation)
  end

  test "should show consultations in order of publication date" do
    earlier_consultation = create(:published_consultation, published_at: 2.days.ago)
    later_consultation = create(:published_consultation, published_at: 1.days.ago)
    organisation = create(:organisation, editions: [earlier_consultation, later_consultation])

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
      name: "unformatted & name",
      about_us: "organisation-about-us"
    )

    get :about, id: organisation

    assert_select ".page_title", text: "unformatted &amp; name &mdash; About"
    assert_select ".body", text: "organisation-about-us"
  end

  SUBPAGE_ACTIONS.each do |action|
    test "should show social media accounts on organisation #{action} subpage" do
      social_media_account = create(:social_media_account)
      organisation = create(:organisation, social_media_accounts: [social_media_account])
      get action, id: organisation
      assert_select ".social_media_accounts"
    end

    test "should show description on organisation #{action} subpage" do
      organisation = create(:organisation, description: "organisation-description")
      get action, id: organisation
      assert_select ".description", text: "organisation-description"
    end
  end

  test "should render the about-us content using govspeak markup" do
    organisation = create(:organisation,
      name: "organisation-name",
      about_us: "body-in-govspeak"
    )

    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :about, id: organisation
    end

    assert_select ".body", text: "body-in-html"
  end

  test "should display corporate publications on about-us page" do
    published_corporate_publication = create(:published_corporate_publication)
    organisation = create(:organisation, editions: [
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

    assert_equal [senior_role, junior_role], assigns(:ministerial_roles).collect(&:model)
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
      assert_select ".current_appointee a[href=#{person_url(person_1)}]", "Fred"
      assert_select "a[href=#{ministerial_role_url(ministerial_role_1)}]", text: "Secretary of State"
    end
    assert_select_object(ministerial_role_2) do
      assert_select ".current_appointee a[href=#{person_url(person_2)}]", "Bob"
      assert_select "a[href=#{ministerial_role_url(ministerial_role_2)}]", text: "Minister of State"
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

  test "shows leading management team members with links to person pages" do
    permanent_secretary = create(:board_member_role, permanent_secretary: true)
    person = create(:person)
    create(:role_appointment, role: permanent_secretary, person: person)
    organisation = create(:organisation, board_member_roles: [permanent_secretary])

    get :management_team, id: organisation

    assert_select permanent_secretary_board_members_selector do
      assert_select_object(permanent_secretary) do
        assert_select "a[href='#{person_url(person)}']"
      end
    end
  end

  test "should not display an empty leading management team section" do
    junior = create(:board_member_role)
    organisation = create(:organisation, board_member_roles: [junior])

    get :management_team, id: organisation

    refute_select permanent_secretary_board_members_selector
  end

  test "shows non-leading management team members with links to person pages" do
    junior = create(:board_member_role)
    person = create(:person)
    create(:role_appointment, role: junior, person: person)
    organisation = create(:organisation, board_member_roles: [junior])

    get :management_team, id: organisation

    assert_select other_board_members_selector do
      assert_select_object(junior) do
        assert_select "a[href='#{person_url(person)}']", text: person.name
      end
    end
  end

  test "should not display an empty non-leading management team section" do
    organisation = create(:organisation)

    get :management_team, id: organisation

    refute_select other_board_members_selector
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
    organisation = create(:organisation, editions: [published_policy, draft_policy])

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

    assert_equal [organisation_a, organisation_b, organisation_c], assigns(:organisations)
  end

  test "should place organisation specific css class on every organisation sub page" do
    ministerial_department = create(:organisation_type, name: "Ministerial Department")
    organisation = create(:organisation, organisation_type: ministerial_department)

    [:show, :about, :consultations, :contact_details, :management_team, :ministers, :policies, :publications].each do |page|
      get page, id: organisation
      assert_select "##{dom_id(organisation)}.#{organisation.slug}.ministerial-department"
    end
  end

  test "shows 10 most recently published editions associated with organisation" do
    editions = 3.times.map { |n| create(:published_policy, published_at: n.days.ago) } +
                3.times.map { |n| create(:published_publication, published_at: (3 + n).days.ago) } +
                3.times.map { |n| create(:published_consultation, published_at: (6 + n).days.ago) } +
                3.times.map { |n| create(:published_speech, published_at: (9 + n).days.ago) }

    organisation = create(:organisation, editions: editions)
    get :show, id: organisation

    assert_select "h1", "Latest"
    editions[0,4].each do |edition|
      assert_select_object edition
    end
    editions[10,2].each do |edition|
      refute_select_object edition
    end
  end

  test "should not show most recently published editions when there are none" do
    organisation = create(:organisation, editions: [])
    get :show, id: organisation

    refute_select "h1", text: "Recently updated"
  end

  test "should show list of links to social media accounts" do
    twitter = create(:social_media_service, name: "Twitter")
    flickr = create(:social_media_service, name: "Flickr")
    twitter_account = create(:social_media_account, social_media_service: twitter, url: "https://twitter.com/#!/bisgovuk")
    flickr_account = create(:social_media_account, social_media_service: flickr, url: "http://www.flickr.com/photos/bisgovuk")
    organisation = create(:organisation, social_media_accounts: [twitter_account, flickr_account])

    get :show, id: organisation

    assert_select ".social_media_accounts" do
      assert_select_object twitter_account
      assert_select_object flickr_account
    end
  end

  test "should not show list of links to social media accounts if there are none" do
    organisation = create(:organisation, social_media_accounts: [])

    get :show, id: organisation

    refute_select ".social_media_accounts"
  end

  private

  def assert_disclaimer_present(organisation)
    assert_select "#organisation_disclaimer" do
      assert_select "a[href='#{organisation.url}']"
    end
  end
end
