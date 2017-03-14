require "test_helper"
require "gds_api/test_helpers/rummager"

class OrganisationsControllerTest < ActionController::TestCase
  include ApplicationHelper
  include FeedHelper
  include FilterRoutesHelper
  include OrganisationControllerTestHelpers
  include GdsApi::TestHelpers::Rummager

  should_be_a_public_facing_controller
  should_display_organisation_page_elements_for(:organisation)
  should_display_organisation_page_elements_for(:executive_office)

  setup do
    rummager_has_no_policies_for_any_type

    content_store_has_item(
      "/government/organisations",
      format: "finder",
      title: "Title of organisations homepage")
  end

  ### Describing :index ###
  test "index should instantiate an OrganisationsIndexPresenter with all organisations which are listable ordered by name" do
    Organisation.stubs(:listable).returns(stub(ordered_by_name_ignoring_prefix: :some_listable_ordered_orgs))
    OrganisationsIndexPresenter.expects(:new).with(:some_listable_ordered_orgs).returns(:some_presented_organisations)
    get :index
    assert_equal :some_presented_organisations, assigns(:organisations)
    assert_template :index
  end

  test "index from the courts route renders the court index" do
    organisation = create(:organisation)
    court = create(:court)
    hmcts_tribunal = create(:hmcts_tribunal)

    get :index, courts_only: true

    assert_template :courts_index
    assert_nil assigns(:organisations)
    assert_equal [court], assigns(:courts)
    assert_equal [hmcts_tribunal], assigns(:hmcts_tribunals)
  end

  view_test "should include a rel='alternate' link to JSON representation of organisations" do
    get :index

    assert_select "link[rel=alternate][type='application/json'][href=?]", api_organisations_url
  end

  view_test "links to the correct path for organisations" do
    organisation = create(:organisation)

    get :index

    assert_select "a[href='/government/organisations/#{organisation.slug}']", text: organisation.name
  end

  view_test "links to the correct paths for courts and tribunals" do
    court = create(:court)
    hmcts_tribunal = create(:hmcts_tribunal)

    get :index, courts_only: true

    assert_select "a[href='/courts-tribunals/#{court.slug}']", text: court.name
    assert_select "a[href='/courts-tribunals/#{hmcts_tribunal.slug}']", text: hmcts_tribunal.name
  end

  view_test "shows a count of organisations" do
    2.times { create(:organisation) }

    get :index

    assert_select "#agencies-and-government-bodies span.count.js-filter-count", text: "2"
  end

  view_test "does not show a count of organisations for courts and tribunals" do
    court = create(:court)
    hmcts_tribunal = create(:hmcts_tribunal)

    get :index, courts_only: true

    refute_select "span.count.js-filter-count"
  end

  view_test "does not show a beta banner on organisations index" do
    get :index

    refute_select "test-govuk-component[data-template=govuk_component-beta_label]"
  end

  view_test "shows a beta banner on courts index" do
    get :index, courts_only: true

    assert_select "test-govuk-component[data-template=govuk_component-beta_label]"
  end

  ### Describing :show ###

  view_test "showing an organisation without a list of contacts doesn't try to create one" do
    # needs to be a view_test so the entire view is rendered
    organisation = create_org_and_stub_content_store(:organisation)
    get :show, id: organisation

    organisation.reload
    refute organisation.has_home_page_contacts_list?
  end

  view_test "provides ids for links with fragment identifiers to jump to relevent sections" do
    management_role = create(:board_member_role)
    management = create(:role_appointment, role: management_role, person: create(:person))
    contact = create(:contact)
    organisation = create_org_and_stub_content_store(:organisation, management_roles: [management_role])
    create(:sub_organisation, parent_organisations: [organisation])
    role = create(:ministerial_role, role_appointments: [create(:role_appointment)])
    create(:organisation_role, organisation: organisation, role: role)
    create(:corporate_information_page, organisation: organisation)
    organisation.add_contact_to_home_page!(contact)

    policy = publishing_api_has_policies(['test-title']).first
    create(:featured_policy, organisation: organisation, policy_content_id: policy["content_id"])

    get :show, id: organisation

    assert_select '#corporate-info'
    assert_select '#high-profile-units'
    assert_select '#management'
    assert_select '#ministers'
    assert_select '#org-contacts'
    assert_select '#people'
    assert_select '#policies'
    assert_select '#what-we-do'
  end

  def self.sets_cache_control_max_age_to_time_of_next_scheduled(edition_type)
    test "#show sets Cache-Control: max-age to the time of the next scheduled #{edition_type}" do
      organisation = create_org_and_stub_content_store(:ministerial_department)
      edition = if block_given?
        yield organisation
      else
        create(edition_type, :scheduled,
          scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2,
          organisations: [organisation])
      end

      Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
        get :show, id: organisation
      end

      assert_cache_control("max-age=#{5.minutes}")
    end
  end

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
    organisation = create_org_and_stub_content_store(:organisation, roles: [chief_of_the_defence_staff])

    get :show, id: organisation

    assert_select_object person do
      assert_select "a[href=?]", person_path(person), text: person.name
    end
  end

  view_test "#show doesn't present expanded navigation for non-department organisations" do
    organisation = create_org_and_stub_content_store(:organisation, organisation_type: OrganisationType.other)
    get :show, id: organisation
    assert_select "nav" do
      refute_select "a[href=?]", announcements_path(departments: [organisation])
      refute_select "a[href=?]", publications_path(departments: [organisation])
      refute_select "a[href=?]", consultations_organisation_path(organisation)
    end
  end

  view_test "#show uses the correct logo type branding" do
    organisation = create_org_and_stub_content_store(:organisation)
    get :show, id: organisation
    assert_select ".organisation-logo-stacked-single-identity"
  end

  view_test "#show indicates when an organisation is not part of the single identity branding" do
    organisation = create_org_and_stub_content_store(:organisation, organisation_logo_type_id: OrganisationLogoType::NoIdentity.id)
    get :show, id: organisation
    assert_select ".organisation-logo-stacked-no-identity"
  end

  view_test "#show uses a custom logo in the h1 tag, instead of usual branding" do
    organisation = create_org_and_stub_content_store(
      :organisation,
      organisation_logo_type_id: OrganisationLogoType::CustomLogo.id,
      logo: fixture_file_upload('logo.png')
    )
    VirusScanHelpers.simulate_virus_scan(organisation.logo)
    get :show, id: organisation
    assert_select %Q{img[alt="#{organisation.name}"][src*="logo.png"]}
  end

  view_test "#show includes the parent organisations for sub-organisations in the header" do
    organisation = create(:organisation, logo_formatted_name: "Ministry of Jam")
    sub_organisation = create_org_and_stub_content_store(:sub_organisation, name: "Marmalade Inspection Board", logo_formatted_name: "Marmalade Inspection Board", parent_organisations: [organisation])

    get :show, id: sub_organisation.slug

    assert_select ".page-header" do
      assert_select "h1", text: sub_organisation.name
      assert_select ".parent-organisations" do
        assert_select "a[href=?]", organisation_path(organisation), text: organisation.name
      end
    end
  end

  view_test "#show uses the correct organisation brand colour" do
    organisation = create_org_and_stub_content_store(:organisation, organisation_brand_colour_id: OrganisationBrandColour::HMGovernment.id)
    get :show, id: organisation
    assert_select ".hm-government-brand-colour"
  end

  test "showing a live organisation renders the show template" do
    organisation = create_org_and_stub_content_store(:organisation, govuk_status: 'live')

    get :show, id: organisation

    assert_template 'show'
  end

  test "showing a live promotional style organisation renders the show promotional template" do
    organisation = create_org_and_stub_content_store(:executive_office, govuk_status: 'live')

    get :show, id: organisation

    assert_template 'show-promotional'
  end

  view_test "promotional template shows featured policies if there are any" do
    organisation = create_org_and_stub_content_store(:executive_office, govuk_status: 'live')
    policies = publishing_api_has_policies(['test-policy'])
    create(:featured_policy, organisation: organisation, policy_content_id: policies.first["content_id"])

    get :show, id: organisation

    assert_select "#featured-policies"
  end

  test "showing a joining organisation renders the not live template" do
    organisation = create_org_and_stub_content_store(:organisation, govuk_status: 'joining')

    get :show, id: organisation

    assert_template 'not_live'
  end

  test "showing an exempt organisation renders the not live template" do
    organisation = create_org_and_stub_content_store(:organisation, govuk_status: 'exempt')

    get :show, id: organisation

    assert_template 'not_live'
  end

  test "showing an transitioning organisation renders the not live template" do
    organisation = create_org_and_stub_content_store(:organisation, govuk_status: 'transitioning')

    get :show, id: organisation

    assert_template 'not_live'
  end

  test "showing a closed organisation renders the not live template" do
    organisation = create_org_and_stub_content_store(:closed_organisation)

    get :show, id: organisation

    assert_template 'not_live'
  end

  view_test "showing a closed organisation does not render the parent_organisations or the url" do
    organisation = create_org_and_stub_content_store(:closed_organisation)

    get :show, id: organisation

    assert_template 'not_live'
    refute_select ".parent_organisations"
    refute_select ".url_link"
  end

  view_test "showing a transitioning court or tribunal does not render the parent_organisations or the url" do
    organisation = create_org_and_stub_content_store(:hmcts_tribunal, govuk_status: 'transitioning')

    get :show, id: organisation, courts_only: true

    assert_template 'not_live'
    refute_select ".parent_organisations"
    refute_select ".url_link"
  end

  view_test "doesn't show a thumbnail if the organisation has no url" do
    organisation = create_org_and_stub_content_store(:organisation, govuk_status: 'exempt', url: '')
    create(:published_corporate_information_page, organisation: organisation)

    get :show, id: organisation

    assert_select ".description a[href=?]", organisation.url
    assert_select ".thumbnail", false
  end

  view_test "doesn't show a thumbnail if the organisation is closed" do
    organisation = create_org_and_stub_content_store(:closed_organisation, url: 'http://madeup-url.com')
    create(:published_corporate_information_page, organisation: organisation)

    get :show, id: organisation

    refute_select ".description a[href=?]", organisation.url
    assert_select ".thumbnail", false
  end

  view_test "should not display an empty published policies section" do
    organisation = create_org_and_stub_content_store(:organisation)
    get :show, id: organisation
    refute_select "#policies"
  end

  view_test "should not display an empty published document sections" do
    organisation = create_org_and_stub_content_store(:organisation)
    get :show, id: organisation
    refute_select "#publications"
    refute_select "#consultations"
    refute_select "#announcements"
    refute_select "#statistics"
  end

  view_test "should not display the child organisations section" do
    organisation = create_org_and_stub_content_store(:organisation)
    get :show, id: organisation
    refute_select "#child_organisations"
  end

  view_test "should not display the parent organisations section" do
    organisation = create_org_and_stub_content_store(:organisation)
    get :show, id: organisation
    refute_select "#parent_organisations"
  end

  view_test "shows that courts are 'administered by' their parent organisation" do
    court = create_org_and_stub_content_store(:court)
    get :show, id: court, courts_only: true
    assert_select "p.parent-organisations", text: /Administered by\s+HMCTS/m
  end

  view_test "shows that HMCTS tribunals are 'administered by' HMCTS" do
    hmcts_tribunal = create_org_and_stub_content_store(:hmcts_tribunal)
    get :show, id: hmcts_tribunal, courts_only: true
    assert_select "p.parent-organisations", text: /Administered by\s+HMCTS/m
  end

  view_test "should display the organisation's policies with content" do
    organisation = create_org_and_stub_content_store(:organisation)
    policy = publishing_api_has_policies(['Welfare reform']).first
    create(:featured_policy, organisation: organisation, policy_content_id: policy["content_id"])

    get :show, id: organisation

    assert_select "#policies" do
      assert_select "a[href='#{policy["base_path"]}']", text: "Welfare reform"

      assert_select "a[href='#{policies_finder_path(organisations: [organisation])}']"
    end
  end

  test "should display organisation's latest three policies" do
    first_three_policy_titles = [
      "Welfare reform",
      "State Pension simplification",
      "State Pension age",
    ]

    organisation = create_org_and_stub_content_store(:organisation)
    policies = publishing_api_has_policies(first_three_policy_titles)
    create(:featured_policy, organisation: organisation, policy_content_id: policies[0]["content_id"])
    create(:featured_policy, organisation: organisation, policy_content_id: policies[1]["content_id"])
    create(:featured_policy, organisation: organisation, policy_content_id: policies[2]["content_id"])

    get :show, id: organisation

    assert_equal first_three_policy_titles, assigns[:policies].map(&:title)
  end

  test "should display 2 announcements in reverse chronological order" do
    organisation = create_org_and_stub_content_store(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    announcement_1 = create(:published_news_article, organisations: [organisation], first_published_at: 2.days.ago)
    announcement_2 = create(:published_speech, role_appointment: role_appointment, first_published_at: 3.days.ago)
    announcement_3 = create(:published_news_article, organisations: [organisation], first_published_at: 1.days.ago)

    get :show, id: organisation

    assert_equal [announcement_3, announcement_1], assigns[:announcements].object
  end

  view_test "should display 2 announcements with details and a link to announcements filter if there are many announcements" do
    organisation = create_org_and_stub_content_store(:organisation)
    announcement_1 = create(:published_news_article, organisations: [organisation], first_published_at: 1.days.ago)
    announcement_2 = create(:published_speech, organisations: [organisation], first_published_at: 2.days.ago.to_date, speech_type: SpeechType::WrittenStatement)
    announcement_3 = create(:published_news_article, organisations: [organisation], first_published_at: 3.days.ago)

    get :show, id: organisation

    assert_select '#announcements' do
      assert_select_object(announcement_1) do
        assert_select "time.public_timestamp[datetime=?]", 1.days.ago.iso8601
        assert_select ".document-type", "Press release"
      end
      assert_select_object(announcement_2) do
        assert_select "time.public_timestamp[datetime=?]", 2.days.ago.to_date.to_datetime.iso8601
        assert_select ".document-type", "Written statement to Parliament"
      end
      refute_select_object(announcement_3)
      assert_select "a[href='#{announcements_filter_path(organisation)}']"
    end
  end

  test "should display 2 consultations in reverse chronological order" do
    organisation = create_org_and_stub_content_store(:organisation)
    consultation_2 = create(:published_consultation, organisations: [organisation], first_published_at: 2.days.ago)
    _consultation_3 = create(:published_consultation, organisations: [organisation], first_published_at: 3.days.ago)
    consultation_1 = create(:published_consultation, organisations: [organisation], first_published_at: 1.day.ago)

    get :show, id: organisation

    assert_equal [consultation_1, consultation_2], assigns[:consultations].object
  end

  view_test "should display 2 consultations with details and a link to publications filter if there are many consultations" do
    organisation = create_org_and_stub_content_store(:organisation)
    consultation_3 = create(:published_consultation, organisations: [organisation], first_published_at: 5.days.ago, opening_at: 5.days.ago, closing_at: 1.days.ago)
    consultation_2 = create(:published_consultation, organisations: [organisation], first_published_at: 4.days.ago, opening_at: 4.days.ago, closing_at: 1.days.ago)
    consultation_1 = create(:published_consultation, organisations: [organisation], first_published_at: 3.days.ago, opening_at: 3.days.ago)
    response = create(:consultation_outcome, consultation: consultation_3, attachments: [
      build(:file_attachment)
    ])

    get :show, id: organisation

    assert_select "#consultations" do
      assert_select_object consultation_1 do
        assert_select '.publication-date time[datetime=?]', 3.days.ago.iso8601
        assert_select '.document-type', "Open consultation"
      end
      assert_select_object consultation_2 do
        assert_select '.publication-date time[datetime=?]', 4.days.ago.iso8601
        assert_select '.document-type', "Closed consultation"
      end
      refute_select_object consultation_3
      assert_select "a[href=?]", publications_filter_path(organisation, publication_filter_option: 'consultations')
    end
  end

  test "should display organisation's latest two non-statistics and non-consultation publications in reverse chronological order" do
    organisation = create_org_and_stub_content_store(:organisation)
    publication_2 = create(:published_publication, organisations: [organisation], first_published_at: 2.days.ago)
    publication_3 = create(:published_publication, organisations: [organisation], first_published_at: 3.days.ago)
    publication_1 = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago)

    consultation = create(:published_consultation, organisations: [organisation], opening_at: 1.days.ago)
    statistics_publication = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago, publication_type: PublicationType::OfficialStatistics)

    get :show, id: organisation

    assert_equal [publication_1, publication_2], assigns[:non_statistics_publications].object
  end

  view_test "should display 2 non-statistics publications with details and a link to publications filter if there are many publications" do
    organisation = create_org_and_stub_content_store(:organisation)
    publication_2 = create(:published_publication, organisations: [organisation], first_published_at: 2.days.ago.to_date, publication_type: PublicationType::PolicyPaper)
    publication_3 = create(:published_publication, organisations: [organisation], first_published_at: 3.days.ago.to_date, publication_type: PublicationType::PolicyPaper)
    publication_1 = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago.to_date, publication_type: PublicationType::OfficialStatistics)

    get :show, id: organisation

    assert_select "#publications" do
      assert_select_object publication_2 do
        assert_select '.publication-date time[datetime=?]', 2.days.ago.to_date.to_datetime.iso8601
        assert_select '.document-type', "Policy paper"
      end
      assert_select_object publication_3
      refute_select_object publication_1
      assert_select "a[href=?]", publications_filter_path(organisation)
    end
  end

  test "should display organisation's latest two statistics publications in reverse chronological order" do
    organisation = create_org_and_stub_content_store(:organisation)
    publication_2 = create(:published_publication, organisations: [organisation], first_published_at: 2.days.ago, publication_type: PublicationType::OfficialStatistics)
    publication_3 = create(:published_publication, organisations: [organisation], first_published_at: 3.days.ago, publication_type: PublicationType::OfficialStatistics)
    publication_1 = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago, publication_type: PublicationType::NationalStatistics)
    get :show, id: organisation
    assert_equal [publication_1, publication_2], assigns[:statistics_publications].object
  end

  view_test "should display 2 statistics publications with details and a link to publications filter if there are many publications" do
    organisation = create_org_and_stub_content_store(:organisation)
    publication_2 = create(:published_publication, organisations: [organisation], first_published_at: 2.days.ago.to_date, publication_type: PublicationType::OfficialStatistics)
    publication_3 = create(:published_publication, organisations: [organisation], first_published_at: 3.days.ago.to_date, publication_type: PublicationType::OfficialStatistics)
    publication_1 = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago.to_date, publication_type: PublicationType::NationalStatistics)

    get :show, id: organisation

    assert_select "#statistics-publications" do
      assert_select_object publication_1 do
        assert_select '.publication-date time[datetime=?]', 1.days.ago.to_date.to_datetime.iso8601
        assert_select '.document-type', "National Statistics"
      end
      assert_select_object publication_2
      refute_select_object publication_3
      assert_select "a[href=?]", publications_filter_path(organisation, publication_filter_option: 'statistics')
    end
  end

  view_test "should exclude corporate information pages from Latest block" do
    organisation = create_org_and_stub_content_store(:organisation)
    cip = create(:published_corporate_information_page, organisation: organisation, first_published_at: 1.day.ago.to_date)
    publication_1 = create(:published_publication, organisations: [organisation], first_published_at: 1.day.ago.to_date, publication_type: PublicationType::NationalStatistics)
    publication_2 = create(:published_publication, organisations: [organisation], first_published_at: 2.day.ago.to_date, publication_type: PublicationType::NationalStatistics)
    publication_3 = create(:published_publication, organisations: [organisation], first_published_at: 3.day.ago.to_date, publication_type: PublicationType::NationalStatistics)
    get :show, id: organisation
    assert_equal [publication_1, publication_2, publication_3], assigns[:recently_updated].take(3)
  end

  view_test "should display sub-organisations" do
    organisation = create_org_and_stub_content_store(:organisation)
    sub_organisation = create(:sub_organisation, parent_organisations: [organisation])

    get :show, id: organisation

    assert_select ".sub_organisations" do
      assert_select_object(sub_organisation)
    end
  end

  view_test "show generates an atom feed with entries for latest activity" do
    organisation = create_org_and_stub_content_store(:organisation, name: "org-name")
    pub = create(:published_publication, organisations: [organisation], first_published_at: 4.weeks.ago.to_date)
    news = create(:published_news_article, organisations: [organisation], first_published_at: 2.weeks.ago)

    get :show, id: organisation, format: :atom

    assert_select_atom_feed do
      assert_select_atom_entries([news, pub])
    end
  end

  view_test "show should include a rel='alternate' link to the organisation's JSON representation" do
    organisation = create_org_and_stub_content_store(:organisation, name: "org-name")

    get :show, id: organisation

    assert_select "link[rel=alternate][type='application/json'][href=?]", api_organisation_url(organisation)
  end

  test "shows ministerial roles in the specified order" do
    junior_role = create(:ministerial_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:ministerial_role, role_appointments: [create(:role_appointment)])
    organisation = create_org_and_stub_content_store(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:ministerial_roles).collect(&:model)
  end

  test "only shows ministerials roles for which there are people currently appointed" do
    assigned_role = create(:ministerial_role, role_appointments: [create(:role_appointment)])
    vacant_role = create(:ministerial_role)
    organisation = create_org_and_stub_content_store(:organisation)
    create(:organisation_role, organisation: organisation, role: assigned_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: vacant_role, ordering: 1)

    get :show, id: organisation

    assert_equal [assigned_role], assigns(:ministerial_roles).collect(&:model)
  end

  test "shows traffic commissioner roles in the specified order" do
    junior_role = create(:traffic_commissioner_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:traffic_commissioner_role, role_appointments: [create(:role_appointment)])
    organisation = create_org_and_stub_content_store(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:traffic_commissioner_roles).collect(&:model)
  end

  test "shows chief professional officer roles in the specified order" do
    junior_role = create(:chief_professional_officer_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:chief_professional_officer_role, role_appointments: [create(:role_appointment)])
    organisation = create_org_and_stub_content_store(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:chief_professional_officer_roles).collect(&:model)
  end

  test "shows judge roles in the specified order" do
    junior_role = create(:judge_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:judge_role, role_appointments: [create(:role_appointment)])
    organisation = create_org_and_stub_content_store(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:judge_roles).collect(&:model)
  end

  test "shows military roles in the specified order" do
    junior_role = create(:military_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:military_role, role_appointments: [create(:role_appointment)])
    organisation = create_org_and_stub_content_store(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:military_roles).collect(&:model)
  end

  view_test "shows links to ministers people pages" do
    minister = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, role: minister, person: person)
    organisation = create_org_and_stub_content_store(:organisation, ministerial_roles: [minister])

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
    organisation = create_org_and_stub_content_store(:organisation, ministerial_roles: [ministerial_role_1, ministerial_role_2])
    minister_in_another_organisation = create(:ministerial_role)

    get :show, id: organisation

    assert_select_object(person_1) do
      assert_select ".current-appointee a[href=?]", person_path(person_1), "Fred"
      assert_select "a[href=?]", ministerial_role_path(ministerial_role_1), text: "Secretary of State"
    end
    assert_select_object(person_2) do
      assert_select ".current-appointee a[href=?]", person_path(person_2), "Bob"
      assert_select "a[href=?]", ministerial_role_path(ministerial_role_2), text: "Minister of State"
    end
    refute_select_object(minister_in_another_organisation)
  end

  view_test "should display the minister's picture if available" do
    ministerial_role = create(:ministerial_role)
    person = create(:person, image: image_fixture_file)
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create_org_and_stub_content_store(:organisation, ministerial_roles: [ministerial_role])
    get :show, id: organisation
    assert_select "img[src*='minister-of-funk.960x640.jpg']"
  end

  view_test "should display an empty space if the minister doesn't have their own picture" do
    ministerial_role = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create_org_and_stub_content_store(:organisation, ministerial_roles: [ministerial_role])
    get :show, id: organisation
    assert_select "div.blank-person div.blank-person-inner"
  end

  view_test "shows management team members with links to person pages" do
    permanent_secretary = create(:board_member_role, permanent_secretary: true)
    senior_person = create(:person)
    create(:role_appointment, role: permanent_secretary, person: senior_person)
    junior = create(:board_member_role)
    junior_person = create(:person)
    create(:role_appointment, role: junior, person: junior_person)
    organisation = create_org_and_stub_content_store(:organisation, management_roles: [permanent_secretary, junior])

    get :show, id: organisation

    assert_select management_selector do
      assert_select_object(senior_person) do
        assert_select "a[href=?]", person_path(senior_person)
      end
      assert_select_object(junior_person) do
        assert_select "a[href=?]", person_path(junior_person)
      end
    end
  end

  view_test "should not display an empty management team section" do
    organisation = create_org_and_stub_content_store(:organisation, management_roles: [])

    get :show, id: organisation

    refute_select management_selector
  end

  view_test "shows special representatives with links to person pages" do
    representative = create(:person)
    special_representative_role = create(:special_representative_role)
    create(:role_appointment, role: special_representative_role, person: representative)

    organisation = create_org_and_stub_content_store(:organisation, special_representative_roles: [special_representative_role])

    get :show, id: organisation

    assert_select special_representative_selector do
      assert_select_object(representative) do
        assert_select "a[href=?]", person_path(representative)
      end
    end
  end

  view_test "should not display an empty special representatives section" do
    organisation = create_org_and_stub_content_store(:organisation, special_representative_roles: [])

    get :show, id: organisation

    refute_select special_representative_selector
  end

  view_test "should place organisation brand colour css class on organisation pages" do
    organisation = create_org_and_stub_content_store(:organisation, organisation_type: OrganisationType.ministerial_department, organisation_brand_colour_id: OrganisationBrandColour::HMGovernment.id)

    get :show, id: organisation
    assert_select "##{dom_id(organisation)}.#{organisation.organisation_brand_colour.class_name}-brand-colour.ministerial-department"
  end

  view_test "should show featured links if there are some" do
    organisation = create_org_and_stub_content_store(:organisation,)
    featured_link = create(:featured_link, linkable: organisation)
    get :show, id: organisation

    assert_select '.featured-links' do
      assert_select "a[href=?]", featured_link.url, text: featured_link.title
    end
  end

  view_test "should set slimmer analytics headers on organisation pages" do
    organisation = create_org_and_stub_content_store(:organisation, acronym: "ABC")
    get :show, id: organisation
    assert_equal "<#{organisation.analytics_identifier}>", response.headers["X-Slimmer-Organisations"]
    assert_equal organisation.acronym.downcase, response.headers["X-Slimmer-Page-Owner"]
  end

  view_test "should show FOI contact information if not exempt" do
    organisation = create_org_and_stub_content_store(:organisation)
    get :show, id: organisation
    assert_select '#freedom-of-information', /Make an FOI request/
  end

  view_test "should show FOI exemption notice if exempt" do
    organisation = create_org_and_stub_content_store(:organisation, foi_exempt: true)
    get :show, id: organisation
    assert_select '#freedom-of-information', /not covered by the Freedom of Information Act/
  end

  view_test "should not show FOI for courts" do
    court = create_org_and_stub_content_store(:court)
    get :show, id: court, courts_only: true
    refute_select '#freedom-of-information'
  end

  view_test "should not show FOI for HMCTS tribunals" do
    hmcts_tribunal = create_org_and_stub_content_store(:hmcts_tribunal)
    get :show, id: hmcts_tribunal, courts_only: true
    refute_select '#freedom-of-information'
  end

  test "should not show Courts from the organisations namespace" do
    assert_raises(ActiveRecord::RecordNotFound) do
      court = create_org_and_stub_content_store(:court)
      get :show, id: court
    end
  end

  test "should not show Tribunals from the organisations namespace" do
    assert_raises(ActiveRecord::RecordNotFound) do
      hmcts_tribunal = create_org_and_stub_content_store(:hmcts_tribunal)
      get :show, id: hmcts_tribunal
    end
  end

  test "should not show Organisations from the courts-and-tribunals namespace" do
    assert_raises(ActiveRecord::RecordNotFound) do
      organisation = create_org_and_stub_content_store(:organisation)
      get :show, id: organisation, courts_only: true
    end
  end

  view_test "shows a beta banner for courts" do
    court = create_org_and_stub_content_store(:court)
    get :show, id: court, courts_only: true
    assert_select "test-govuk-component[data-template=govuk_component-beta_label]"
  end

  view_test "shows a beta banner for HMCTS tribunals" do
    hmcts_tribunal = create_org_and_stub_content_store(:hmcts_tribunal)
    get :show, id: hmcts_tribunal, courts_only: true
    assert_select "test-govuk-component[data-template=govuk_component-beta_label]"
  end

  view_test "does not show a beta banner for organisations" do
    organisation = create_org_and_stub_content_store(:organisation)
    get :show, id: organisation
    refute_select "test-govuk-component[data-template=govuk_component-beta_label]"
  end

  view_test "organisations show the 'About Us' summary and link to page under 'What we do'" do
    organisation = create_org_and_stub_content_store(:organisation, parent_organisations: [create_org_and_stub_content_store(:organisation)])
    create(:about_corporate_information_page, organisation: organisation, summary: "This is *what* we do")
    get :show, id: organisation

    assert_select "#what-we-do" do
      assert_select "h1", text: "What we do"
      assert_select ".overview", text: /This is \*what\* we do/
      assert_select ".overview a", text: /Read more about what we do/
      assert_select ".parent_organisations", text: /works with the/
    end
  end

  view_test "courts show the 'About Us' body as govspeak under 'What we do', with no link to the page" do
    court = create_org_and_stub_content_store(:court)
    create(:about_corporate_information_page, organisation: court, body: "This is *who* we are")
    get :show, id: court, courts_only: true

    assert_select "#what-we-do" do
      assert_select "h1", text: "What we do"
      assert_select ".overview", text: /This is who we are/
      refute_select ".overview a", text: /Read more about what we do/
      refute_select ".parent_organisations"
    end
  end

  view_test "HMCTS tribunals show the 'About Us' body as govspeak under 'Who we are', with no link to the page" do
    hmcts_tribunal = create_org_and_stub_content_store(:hmcts_tribunal)
    create(:about_corporate_information_page, organisation: hmcts_tribunal, body: "This is *who* we are")
    get :show, id: hmcts_tribunal, courts_only: true

    assert_select "#what-we-do" do
      assert_select "h1", text: "What we do"
      assert_select ".overview", text: /This is who we are/
      refute_select ".overview a", text: /Read more about what we do/
      refute_select ".parent_organisations"
    end
  end

  view_test "auto-links comments in contacts" do
    organisation = create_org_and_stub_content_store(:organisation)
    contact = create(:contact, comments: "This is a link: http://www.example.com")
    organisation.add_contact_to_home_page!(contact)

    get :show, id: organisation

    assert_select ".comments", text: "This is a link: http://www.example.com" do
      assert_select "a[href='http://www.example.com']", text: "http://www.example.com"
    end
  end

  view_test "organisations shows the default Jobs link" do
    organisation = create_org_and_stub_content_store(:organisation)
    get :show, id: organisation
    assert_select "a", text: "Jobs"
  end

  view_test "courts don't show a Jobs link" do
    court = create_org_and_stub_content_store(:court)
    get :show, id: court, courts_only: true
    refute_select "a", text: "Jobs"
  end

  view_test "HMCTS tribunals don't show a Jobs link" do
    hmcts_tribunal = create_org_and_stub_content_store(:hmcts_tribunal)
    get :show, id: hmcts_tribunal, courts_only: true
    refute_select "a", text: "Jobs"
  end

  private

  def assert_disclaimer_present(organisation)
    assert_select "#organisation_disclaimer" do
      assert_select "a[href=?]", organisation.url
    end
  end
end
