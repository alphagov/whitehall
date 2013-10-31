require "test_helper"

class OrganisationsControllerTest < ActionController::TestCase
  include FilterRoutesHelper
  include OrganisationControllerTestHelpers

  should_be_a_public_facing_controller
  should_display_organisation_page_elements_for(:organisation)
  should_display_organisation_page_elements_for(:executive_office)


  ### Describing :index ###
  test "index should instanciate an OrganisationsIndexPresenter with all organisations which are listable ordered by name" do
    Organisation.stubs(:listable).returns(stub(ordered_by_name_ignoring_prefix: :some_listable_ordered_orgs))
    OrganisationsIndexPresenter.expects(:new).with(:some_listable_ordered_orgs).returns(:some_presented_organisations)
    get :index
    assert_equal :some_presented_organisations, assigns(:organisations)
  end

  view_test "should display a list of executive offices" do
    organisation = create(:organisation, organisation_type: OrganisationType.executive_office)

    get :index

    assert_select '#executive-offices' do
      assert_select_object(organisation)
    end
  end

  view_test "should display a list of ministerial departments" do
    organisation_1 = create(:organisation, organisation_type: OrganisationType.ministerial_department)
    organisation_2 = create(:organisation, organisation_type: OrganisationType.ministerial_department)
    organisation_3 = create(:organisation, organisation_type: OrganisationType.ministerial_department)

    get :index

    assert_select '#ministerial-departments' do
      assert_select '.js-filter-count', text: '3'
      assert_select_object(organisation_1)
    end
  end

  view_test "should display a list of non-ministerial departments" do
    organisation_1 = create(:organisation, organisation_type: OrganisationType.non_ministerial_department)
    organisation_2 = create(:organisation, organisation_type: OrganisationType.non_ministerial_department)

    get :index

    assert_select '#non-ministerial-departments' do
      assert_select '.js-filter-count', text: '2'
      assert_select_object(organisation_1)
    end
  end

  view_test "should display a list of public corporation organisations" do
    organisation_1 = create(:organisation, organisation_type: OrganisationType.public_corporation)
    organisation_2 = create(:organisation, organisation_type: OrganisationType.public_corporation)

    get :index

    assert_select '#public-corporations' do
      assert_select '.js-filter-count', text: '2'
      assert_select_object(organisation_1)
    end
  end

  view_test "should display a list of devolved administrations" do
    organisation_1 = create(:devolved_administration)
    organisation_2 = create(:devolved_administration)

    get :index

    assert_select '#devolved-administrations' do
      assert_select '.js-filter-count', text: '2'
      assert_select_object(organisation_1)
    end
  end

  view_test "index shouldn't include sub-organisations" do
    sub_organisation = create(:sub_organisation)

    get :index

    refute_select_object(sub_organisation)
  end

  view_test 'should show sub-organisations nested under parent' do
    organisation_1 = create(:organisation, organisation_type: OrganisationType.ministerial_department)
    organisation_2 = create(:organisation, organisation_type: OrganisationType.non_ministerial_department)
    child_organisation_1 = create(:organisation, parent_organisations: [organisation_1])
    child_organisation_2 = create(:organisation, parent_organisations: [organisation_2])

    get :index

    assert_select_object(organisation_1) do
      assert_select_object(child_organisation_1)
    end
    assert_select_object(organisation_2) do
      assert_select_object(child_organisation_2)
    end
  end

  view_test "should include a rel='alternate' link to JSON representation of organisations" do
    get :index

    assert_select "link[rel=alternate][type=application/json][href=#{api_organisations_url}]"
  end


  ### Describing :show ###

  view_test "shows organisation description" do
    organisation = create(:organisation,
      description: "organisation-description"
    )
    get :show, id: organisation
    assert_select ".organisation .description", text: "organisation-description"
  end

  view_test "showing an organisation without a list of contacts doesn't try to create one" do
    # needs to be a view_test so the entire view is rendered
    organisation = create(:organisation)
    get :show, id: organisation

    organisation.reload
    refute organisation.has_home_page_contacts_list?
  end

  view_test "provides ids for links with fragment identifiers to jump to relevent sections" do
    topic = create(:topic, published_edition_count: 1)
    management_role = create(:board_member_role)
    management = create(:role_appointment, role: management_role, person: create(:person))
    organisation = create(:organisation, topics: [topic], management_roles: [management_role])
    create(:sub_organisation, parent_organisations: [organisation])
    create(:published_policy, organisations: [organisation], topics: [topic])
    role = create(:ministerial_role, role_appointments: [create(:role_appointment)])
    create(:organisation_role, organisation: organisation, role: role)
    create(:corporate_information_page, organisation: organisation)

    get :show, id: organisation

    assert_select '#corporate-info'
    assert_select '#high-profile-units'
    assert_select '#management'
    assert_select '#ministers'
    assert_select '#org-contacts'
    assert_select '#people'
    assert_select '#policies'
    assert_select '#topics'
    assert_select '#what-we-do'
  end

  def self.sets_cache_control_max_age_to_time_of_next_scheduled(edition_type)
    test "#show sets Cache-Control: max-age to the time of the next scheduled #{edition_type}" do
      user = login_as(:departmental_editor)
      organisation = create(:ministerial_department)
      edition = if block_given?
        yield organisation
      else
        create(edition_type, :draft,
          scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2,
          organisations: [organisation])
      end
      assert edition.perform_force_schedule

      Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
        get :show, id: organisation
      end

      assert_cache_control("max-age=#{5.minutes}")
    end
  end

  sets_cache_control_max_age_to_time_of_next_scheduled(:policy)
  sets_cache_control_max_age_to_time_of_next_scheduled(:publication)
  sets_cache_control_max_age_to_time_of_next_scheduled(:consultation)
  sets_cache_control_max_age_to_time_of_next_scheduled(:speech) do |organisation|
    ministerial_role = FactoryGirl.create(:ministerial_role, organisations: [organisation])
    role_appointment = FactoryGirl.create(:role_appointment, role: ministerial_role)
    FactoryGirl.create(:speech, :draft,
      scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2,
      role_appointment: role_appointment)
  end
  sets_cache_control_max_age_to_time_of_next_scheduled(:news_article)

  view_test "#show links to the chief of the defence staff" do
    chief_of_the_defence_staff = create(:military_role, chief_of_the_defence_staff: true)
    person = create(:person)
    create(:role_appointment, role: chief_of_the_defence_staff, person: person)
    organisation = create(:organisation, roles: [chief_of_the_defence_staff])

    get :show, id: organisation

    assert_select_object person do
      assert_select "a[href=?]", person_path(person), text: person.name
    end
  end

  view_test "#show doesn't present expanded navigation for non-department organisations" do
    organisation = create(:organisation, organisation_type: OrganisationType.other)
    get :show, id: organisation
    assert_select "nav" do
      refute_select "a[href=?]", announcements_path(departments: [organisation])
      refute_select "a[href=?]", publications_path(departments: [organisation])
      refute_select "a[href=?]", consultations_organisation_path(organisation)
    end
  end

  view_test "#show uses the correct logo type branding" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select ".organisation-logo-stacked-single-identity"
  end

  view_test "#show indicates when an organisation is not part of the single identity branding" do
    organisation = create(:organisation, organisation_logo_type_id: OrganisationLogoType::NoIdentity.id)
    get :show, id: organisation
    assert_select ".organisation-logo-stacked-no-identity"
  end

  view_test "#show uses a custom logo in the h1 tag, instead of usual branding" do
    organisation = create(
      :organisation,
      organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
      logo: fixture_file_upload('logo.png')
    )
    VirusScanHelpers.simulate_virus_scan(organisation.logo)
    get :show, id: organisation
    assert_select %Q{img[alt="#{organisation.name}"][src*="logo.png"]}
  end

  view_test "#show includes the parent organisation branding on a sub-organisation" do
    organisation = create(:organisation, logo_formatted_name: "Ministry of Jam")
    sub_organisation = create(:sub_organisation, name: "Marmalade Inspection Board", parent_organisations: [organisation])

    get :show, id: sub_organisation

    assert_select ".sub-organisation-name" do
      assert_select "h1", sub_organisation.name
      assert_select ".organisations-icon-list" do
        assert_select_object organisation
      end
    end
  end

  view_test "#show uses the correct organisation brand colour" do
    organisation = create(:organisation, organisation_brand_colour_id: OrganisationBrandColour::HMGovernment.id)
    get :show, id: organisation
    assert_select ".hm-government-brand-colour"
  end

  test "showing a live organisation renders the show template" do
    organisation = create(:organisation, govuk_status: 'live')

    get :show, id: organisation

    assert_template 'show'
  end

  test "showing a live executive office organisation renders the show external-office template" do
    organisation = create(:executive_office, govuk_status: 'live')

    get :show, id: organisation

    assert_template 'show-executive-office'
  end

  test "showing a joining organisation renders the not live template" do
    organisation = create(:organisation, govuk_status: 'joining')

    get :show, id: organisation

    assert_template 'not_live'
  end

  test "showing an exempt organisation renders the not live template" do
    organisation = create(:organisation, govuk_status: 'exempt')

    get :show, id: organisation

    assert_template 'not_live'
  end

  test "showing an transitioning organisation renders the not live template" do
    organisation = create(:organisation, govuk_status: 'transitioning')

    get :show, id: organisation

    assert_template 'not_live'
  end

  test "showing a closed organisation renders the not live template" do
    organisation = create(:organisation, govuk_status: 'closed')

    get :show, id: organisation

    assert_template 'not_live'
  end

  view_test "doesn't show a thumbnail if the organisation has no url" do
    organisation = create(:organisation, govuk_status: 'exempt', url: '')

    get :show, id: organisation

    assert_select ".description a[href=?]", organisation.url
    assert_select ".thumbnail", false
  end

  view_test "should not display an empty published policies section" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#policies"
  end

  view_test "should not display an empty published document sections" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#publications"
    refute_select "#consultations"
    refute_select "#announcements"
    refute_select "#statistics"
  end

  view_test "should not display the child organisations section" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#child_organisations"
  end

  view_test "should not display the parent organisations section" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#parent_organisations"
  end

  view_test "should display the organisation's topics with content" do
    topics = [0, 1, 2].map { |n| create(:topic, published_edition_count: n) }
    organisation = create(:organisation, topics: topics)
    get :show, id: organisation
    assert_select "#topics" do
      assert_select_object topics[1]
      assert_select_object topics[2]
      refute_select_object topics[0]
    end
  end

  view_test "should display link to policies filter if there are many policies" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    organisation = create(:organisation, topics: [topic_1, topic_2])
    create(:published_policy, organisations: [organisation], topics: [topic_1])
    create(:published_policy, organisations: [organisation], topics: [topic_2])
    create(:published_policy, organisations: [organisation], topics: [topic_2])
    create(:published_policy, organisations: [organisation], topics: [topic_1])

    get :show, id: organisation

    assert_select '#policies' do
      assert_select "a[href='#{policies_filter_path(organisation)}']"
    end
  end

  view_test "should not display an empty topics section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#topics", count: 0
  end

  view_test "should display the organisation's policies with content" do
    organisation = create(:organisation)
    policy = create(:published_policy, organisations: [organisation], summary: "policy-summary")
    get :show, id: organisation
    assert_select "#policies" do
      assert_select_object policy do
        assert_select '.summary', text: "policy-summary"
      end
    end
  end

  test "should display organisation's latest three policies" do
    organisation = create(:organisation)
    policy_2 = create(:published_policy, organisations: [organisation], first_published_at: 2.days.ago)
    policy_4 = create(:published_policy, organisations: [organisation], first_published_at: 4.days.ago)
    policy_3 = create(:published_policy, organisations: [organisation], first_published_at: 3.days.ago)
    policy_1 = create(:published_policy, organisations: [organisation], first_published_at: 1.day.ago)
    get :show, id: organisation
    assert_equal [policy_1, policy_2, policy_3], assigns[:policies].object
  end

  test "should display 2 announcements in reverse chronological order" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    announcement_1 = create(:published_news_article, organisations: [organisation], first_published_at: 2.days.ago)
    announcement_2 = create(:published_speech, role_appointment: role_appointment, first_published_at: 3.days.ago)
    announcement_3 = create(:published_news_article, organisations: [organisation], first_published_at: 1.days.ago)

    get :show, id: organisation

    assert_equal [announcement_3, announcement_1], assigns[:announcements].object
  end

  view_test "should display 2 announcements with details and a link to announcements filter if there are many announcements" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    announcement_1 = create(:published_news_article, organisations: [organisation], first_published_at: 1.days.ago)
    announcement_2 = create(:published_speech, role_appointment: role_appointment, first_published_at: 2.days.ago.to_date, speech_type: SpeechType::WrittenStatement)
    announcement_3 = create(:published_news_article, organisations: [organisation], first_published_at: 3.days.ago)

    get :show, id: organisation

    assert_select '#announcements' do
      assert_select_object(announcement_1) do
        assert_select "abbr.public_timestamp[title=?]", 1.days.ago.iso8601
        assert_select ".document-type", "Press release"
      end
      assert_select_object(announcement_2) do
        assert_select "abbr.public_timestamp[title=?]", 2.days.ago.to_date.to_datetime.iso8601
        assert_select ".document-type", "Written statement to Parliament"
      end
      refute_select_object(announcement_3)
      assert_select "a[href='#{announcements_filter_path(organisation)}']"
    end
  end

  test "should display 2 consultations in reverse chronological order" do
    organisation = create(:organisation)
    consultation_2 = create(:published_consultation, organisations: [organisation], opening_at: 2.days.ago)
    consultation_3 = create(:published_consultation, organisations: [organisation], opening_at: 3.days.ago)
    consultation_1 = create(:published_consultation, organisations: [organisation], opening_at: 1.day.ago)

    get :show, id: organisation

    assert_equal [consultation_1, consultation_2], assigns[:consultations].object
  end

  view_test "should display 2 consultations with details and a link to publications filter if there are many consultations" do
    organisation = create(:organisation)
    consultation_3 = create(:published_consultation, organisations: [organisation], opening_at: 5.days.ago, closing_at: 1.days.ago)
    consultation_2 = create(:published_consultation, organisations: [organisation], opening_at: 4.days.ago, closing_at: 1.days.ago)
    consultation_1 = create(:published_consultation, organisations: [organisation], opening_at: 3.days.ago)
    response_attachment = create(:file_attachment)
    response = create(:consultation_outcome, consultation: consultation_3)
    response.attachments << response_attachment

    get :show, id: organisation

    assert_select "#consultations" do
      assert_select_object consultation_1 do
        assert_select '.publication-date abbr[title=?]', 3.days.ago.iso8601
        assert_select '.document-type', "Open consultation"
      end
      assert_select_object consultation_2 do
        assert_select '.publication-date abbr[title=?]', 4.days.ago.iso8601
        assert_select '.document-type', "Closed consultation"
      end
      refute_select_object consultation_3
      assert_select "a[href='#{publications_filter_path(organisation, publication_filter_option: 'consultations').gsub('&', '&amp;')}']"
    end
  end

  test "should display organisation's latest two non-statistics and non-consultation publications in reverse chronological order" do
    organisation = create(:organisation)
    publication_2 = create(:published_publication, organisations: [organisation], first_published_at: 2.days.ago)
    publication_3 = create(:published_publication, organisations: [organisation], first_published_at: 3.days.ago)
    publication_1 = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago)

    consultation = create(:published_consultation, organisations: [organisation], opening_at: 1.days.ago)
    statistics_publication = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago, publication_type: PublicationType::Statistics)

    get :show, id: organisation

    assert_equal [publication_1, publication_2], assigns[:non_statistics_publications].object
  end

  view_test "should display 2 non-statistics publications with details and a link to publications filter if there are many publications" do
    organisation = create(:organisation)
    publication_2 = create(:published_publication, organisations: [organisation], first_published_at: 2.days.ago.to_date, publication_type: PublicationType::PolicyPaper)
    publication_3 = create(:published_publication, organisations: [organisation], first_published_at: 3.days.ago.to_date, publication_type: PublicationType::PolicyPaper)
    publication_1 = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago.to_date, publication_type: PublicationType::Statistics)

    get :show, id: organisation

    assert_select "#publications" do
      assert_select_object publication_2 do
        assert_select '.publication-date abbr[title=?]', 2.days.ago.to_date.to_datetime.iso8601
        assert_select '.document-type', "Policy paper"
      end
      assert_select_object publication_3
      refute_select_object publication_1
      assert_select "a[href='#{publications_filter_path(organisation)}']"
    end
  end

  test "should display organisation's latest two statistics publications in reverse chronological order" do
    organisation = create(:organisation)
    publication_2 = create(:published_publication, organisations: [organisation], first_published_at: 2.days.ago, publication_type: PublicationType::Statistics)
    publication_3 = create(:published_publication, organisations: [organisation], first_published_at: 3.days.ago, publication_type: PublicationType::Statistics)
    publication_1 = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago, publication_type: PublicationType::NationalStatistics)
    get :show, id: organisation
    assert_equal [publication_1, publication_2], assigns[:statistics_publications].object
  end

  view_test "should display 2 statistics publications with details and a link to publications filter if there are many publications" do
    organisation = create(:organisation)
    publication_2 = create(:published_publication, organisations: [organisation], first_published_at: 2.days.ago.to_date, publication_type: PublicationType::Statistics)
    publication_3 = create(:published_publication, organisations: [organisation], first_published_at: 3.days.ago.to_date, publication_type: PublicationType::Statistics)
    publication_1 = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago.to_date, publication_type: PublicationType::NationalStatistics)

    get :show, id: organisation

    assert_select "#statistics-publications" do
      assert_select_object publication_1 do
        assert_select '.publication-date abbr[title=?]', 1.days.ago.to_date.to_datetime.iso8601
        assert_select '.document-type', "Statistics - national statistics"
      end
      assert_select_object publication_2
      refute_select_object publication_3
      assert_select "a[href='#{publications_filter_path(organisation, publication_filter_option: 'statistics').gsub('&', '&amp;')}']"
    end
  end

  view_test "should display sub-organisations" do
    organisation = create(:organisation)
    sub_organisation = create(:sub_organisation, parent_organisations: [organisation])

    get :show, id: organisation

    assert_select ".sub_organisations" do
      assert_select_object(sub_organisation)
    end
  end

  view_test "show generates an atom feed with entries for latest activity" do
    organisation = create(:organisation, name: "org-name")
    pub = create(:published_publication, organisations: [organisation], first_published_at: 4.weeks.ago.to_date)
    pol = create(:published_policy, organisations: [organisation], first_published_at: 2.weeks.ago)

    get :show, id: organisation, format: :atom

    assert_select_atom_feed do
      assert_select_atom_entries([pol, pub])
    end
  end

  view_test "show should include a rel='alternate' link to the organisation's JSON representation" do
    organisation = create(:organisation, name: "org-name")

    get :show, id: organisation

    assert_select "link[rel=alternate][type=application/json][href=#{api_organisation_url(organisation)}]"
  end

  test "shows ministerial roles in the specified order" do
    junior_role = create(:ministerial_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:ministerial_role, role_appointments: [create(:role_appointment)])
    organisation = create(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:ministerial_roles).collect(&:model)
  end

  test "only shows ministerials roles for which there are people currently appointed" do
    assigned_role = create(:ministerial_role, role_appointments: [create(:role_appointment)])
    vacant_role = create(:ministerial_role)
    organisation = create(:organisation)
    create(:organisation_role, organisation: organisation, role: assigned_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: vacant_role, ordering: 1)

    get :show, id: organisation

    assert_equal [assigned_role], assigns(:ministerial_roles).collect(&:model)
  end

  test "shows traffic commissioner roles in the specified order" do
    junior_role = create(:traffic_commissioner_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:traffic_commissioner_role, role_appointments: [create(:role_appointment)])
    organisation = create(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:traffic_commissioner_roles).collect(&:model)
  end

  test "shows traffic chief professional officer roles in the specified order" do
    junior_role = create(:chief_professional_officer_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:chief_professional_officer_role, role_appointments: [create(:role_appointment)])
    organisation = create(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:chief_professional_officer_roles).collect(&:model)
  end

  test "shows military roles in the specified order" do
    junior_role = create(:military_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:military_role, role_appointments: [create(:role_appointment)])
    organisation = create(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:military_roles).collect(&:model)
  end

  view_test "shows links to ministers people pages" do
    minister = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, role: minister, person: person)
    organisation = create(:organisation, ministerial_roles: [minister])

    get :show, id: organisation

    assert_select_object person do
      assert_select "a[href=?]", person_path(person), text: person.name
    end
  end

  view_test "shows names and roles of those ministers associated with organisation" do
    person_1 = create(:person, forename: "Fred")
    person_2 = create(:person, forename: "Bob")
    ministerial_role_1 = create(:ministerial_role, name: "Secretary of State")
    ministerial_role_2 = create(:ministerial_role, name: "Minister of State")
    create(:role_appointment, person: person_1, role: ministerial_role_1)
    create(:role_appointment, person: person_2, role: ministerial_role_2)
    organisation = create(:organisation, ministerial_roles: [ministerial_role_1, ministerial_role_2])
    minister_in_another_organisation = create(:ministerial_role)

    get :show, id: organisation

    assert_select_object(person_1) do
      assert_select ".current-appointee a[href=#{person_path(person_1)}]", "Fred"
      assert_select "a[href=#{ministerial_role_path(ministerial_role_1)}]", text: "Secretary of State"
    end
    assert_select_object(person_2) do
      assert_select ".current-appointee a[href=#{person_path(person_2)}]", "Bob"
      assert_select "a[href=#{ministerial_role_path(ministerial_role_2)}]", text: "Minister of State"
    end
    refute_select_object(minister_in_another_organisation)
  end

  view_test "should display the minister's picture if available" do
    ministerial_role = create(:ministerial_role)
    person = create(:person, image: image_fixture_file)
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create(:organisation, ministerial_roles: [ministerial_role])
    get :show, id: organisation
    assert_select "img[src*=minister-of-funk.960x640.jpg]"
  end

  view_test "should display a generic image if the minister doesn't have their own picture" do
    ministerial_role = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create(:organisation, ministerial_roles: [ministerial_role])
    get :show, id: organisation
    assert_select "img[src*=blank-person.png]"
  end

  view_test "shows management team members with links to person pages" do
    permanent_secretary = create(:board_member_role, permanent_secretary: true)
    senior_person = create(:person)
    create(:role_appointment, role: permanent_secretary, person: senior_person)
    junior = create(:board_member_role)
    junior_person = create(:person)
    create(:role_appointment, role: junior, person: junior_person)
    organisation = create(:organisation, management_roles: [permanent_secretary, junior])

    get :show, id: organisation

    assert_select management_selector do
      assert_select_object(senior_person) do
        assert_select "a[href='#{person_path(senior_person)}']"
      end
      assert_select_object(junior_person) do
        assert_select "a[href='#{person_path(junior_person)}']"
      end
    end
  end

  view_test "should not display an empty management team section" do
    organisation = create(:organisation, management_roles: [])

    get :show, id: organisation

    refute_select management_selector
  end

  view_test "shows special representatives with links to person pages" do
    representative = create(:person)
    special_representative_role = create(:special_representative_role)
    create(:role_appointment, role: special_representative_role, person: representative)

    organisation = create(:organisation, special_representative_roles: [special_representative_role])

    get :show, id: organisation

    assert_select special_representative_selector do
      assert_select_object(representative) do
        assert_select "a[href='#{person_path(representative)}']"
      end
    end
  end

  view_test "should not display an empty special representatives section" do
    organisation = create(:organisation, special_representative_roles: [])

    get :show, id: organisation

    refute_select special_representative_selector
  end

  view_test "should place organisation brand colour css class on every organisation sub page" do
    organisation = create(:organisation, organisation_type: OrganisationType.ministerial_department, organisation_brand_colour_id: OrganisationBrandColour::HMGovernment.id)

    [:show, :about].each do |page|
      get page, id: organisation
      assert_select "##{dom_id(organisation)}.#{organisation.organisation_brand_colour.class_name}-brand-colour.ministerial-department"
    end
  end

  view_test "should show top tasks if there are some" do
    organisation = create(:organisation,)
    top_task = create(:top_task, linkable: organisation)
    get :show, id: organisation

    assert_select '.top-tasks' do
      assert_select "a[href='#{top_task.url}']", text: top_task.title
    end
  end

  view_test "should not top tasks on suborg pages" do
    organisation = create(:organisation)
    top_task = create(:top_task, linkable: organisation)
    sub_organisation = create(:sub_organisation, parent_organisations: [organisation])

    get :show, id: sub_organisation

    refute_select "a[href='#{top_task.url}']", text: top_task.title
  end



  ### Describing :about ###

  view_test "should show description on organisation about subpage" do
    organisation = create(:organisation, description: "organisation-description")
    get :about, id: organisation
    assert_select ".description", text: "organisation-description"
  end

  view_test "should show links to the alternate languages for a translated organisation" do
    organisation = create(:organisation, description: "organisation-description", translated_into: [:fr])
    get :about, id: organisation
    expected_url = about_organisation_path(organisation, locale: :fr)
    assert_select ".available-languages a[href='#{expected_url}']", text: Locale.new(:fr).native_language_name
  end

  view_test "should render the about-us content using govspeak markup" do
    organisation = create(:organisation,
      name: "organisation-name",
      about_us: "body-in-govspeak"
    )

    govspeak_transformation_fixture "body-in-govspeak" => "body-in-html" do
      get :about, id: organisation
    end

    assert_select ".body", text: "body-in-html"
  end

  view_test "should display published corporate publications on about-us page" do
    published_corporate_publication = create(:published_corporate_publication)
    draft_corporate_publication = create(:draft_corporate_publication)

    organisation = create(:organisation, editions: [
      published_corporate_publication,
      draft_corporate_publication
    ])

    get :about, id: organisation

    assert_select_object(published_corporate_publication)
    refute_select_object(draft_corporate_publication)
  end

  test "should display published corporate publications on about-us page in order published" do
    old_published_corporate_publication = create(:published_corporate_publication, first_published_at: Date.parse('2012-01-01'))
    new_published_corporate_publication = create(:published_corporate_publication, first_published_at: Date.parse('2012-01-03'))
    middle_published_corporate_publication = create(:published_corporate_publication, first_published_at: Date.parse('2012-01-02'))

    organisation = create(:organisation, editions: [
      old_published_corporate_publication,
      new_published_corporate_publication,
      middle_published_corporate_publication,
    ])

    get :about, id: organisation

    assert_equal [
      new_published_corporate_publication,
      middle_published_corporate_publication,
      old_published_corporate_publication
    ], assigns(:corporate_publications)
  end

  view_test "should display link to corporate information pages on about-us page" do
    organisation = create(:organisation)
    corporate_information_page = create(:corporate_information_page, organisation: organisation)
    get :about, id: organisation
    assert_select "a[href='#{organisation_corporate_information_page_path(organisation, corporate_information_page)}']"
  end

  view_test "should not display corporate information section on about-us page if there are no corporate publications" do
    organisation = create(:organisation)
    get :about, id: organisation
    refute_select "#corporate-information"
  end

  view_test "should show FOI contact information if not exempt" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select '#freedom-of-information', /Make an FOI request/
  end

  view_test "should show FOI exemption notice if exempt" do
    organisation = create(:organisation, foi_exempt: true)
    get :show, id: organisation
    assert_select '#freedom-of-information', /not covered by the Freedom of Information Act/
  end

  private

  def assert_disclaimer_present(organisation)
    assert_select "#organisation_disclaimer" do
      assert_select "a[href='#{organisation.url}']"
    end
  end
end
