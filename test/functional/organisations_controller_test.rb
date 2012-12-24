require "test_helper"

class OrganisationsControllerTest < ActionController::TestCase
  include ActionDispatch::Routing::UrlFor
  include PublicDocumentRoutesHelper
  include FilterRoutesHelper

  should_be_a_public_facing_controller

  test "should display a list of organisations" do
    ministerial_org_type = create(:ministerial_organisation_type)

    organisation_1 = create(:organisation, organisation_type_id: ministerial_org_type.id)

    get :index

    assert_select_object(organisation_1)
  end

  test "should display a list of non-ministerial departments" do
    non_ministerial_org_type = create(:non_ministerial_organisation_type)
    organisation = create(:organisation, organisation_type_id: non_ministerial_org_type.id)

    get :index

    assert_select '#agencies-and-public-bodies'
    assert_select '.other-departments' do
      assert_select_object(organisation)
    end
  end

  test "should display a list of public corporation organisations" do
    public_corporation_org_type = create(:public_corporation_organisation_type)
    organisation = create(:organisation, organisation_type_id: public_corporation_org_type.id)

    get :index

    assert_select '#public-corporations'
    assert_select '.other-departments' do
      assert_select_object(organisation)
    end
  end

  test "index shouldn't include sub-organisations" do
    sub_organisation = create(:sub_organisation)

    get :index

    refute_select_object(sub_organisation)
  end

  test "index avoids n+1 selects" do
    ministerial_org = create(:ministerial_organisation_type)
    non_ministerial_org = create(:non_ministerial_organisation_type)
    public_corporation_org = create(:public_corporation_organisation_type)

    4.times { create(:organisation, organisation_type_id: ministerial_org.id) }
    3.times { create(:organisation, organisation_type_id: non_ministerial_org.id) }
    3.times { create(:organisation, organisation_type_id: public_corporation_org.id) }
    queries_used = count_queries { get :index }
    assert 18 > queries_used, "Expected less than 18 queries, #{queries_used} were counted"
  end

  test "shows organisation name and description" do
    organisation = create(:organisation,
      logo_formatted_name: "unformatted name",
      description: "organisation-description"
    )
    get :show, id: organisation
    assert_select ".organisation h1", text: "unformatted name"
    assert_select ".organisation .description", text: "organisation-description"
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
      assert edition.schedule_as(user, force: true)

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

  test "#show links to the chief of the defence staff" do
    chief_of_the_defence_staff = create(:military_role, chief_of_the_defence_staff: true)
    person = create(:person)
    create(:role_appointment, role: chief_of_the_defence_staff, person: person)
    organisation = create(:organisation, roles: [chief_of_the_defence_staff])

    get :show, id: organisation

    assert_select_object person do
      assert_select "a[href=?]", person_path(person), text: person.name
    end
  end

  test "#show doesn't present expanded navigation for non-department organisations" do
    organisation = create(:organisation, organisation_type: create(:organisation_type, name: "Other"))
    get :show, id: organisation
    assert_select "nav" do
      refute_select "a[href=?]", announcements_path(departments: [organisation])
      refute_select "a[href=?]", publications_path(departments: [organisation])
      refute_select "a[href=?]", consultations_organisation_path(organisation)
    end
  end

  test "#show uses the correct logo type branding" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select ".organisation-logo-stacked-single-identity"
  end

  test "#show indicates when an organisation is not part of the single identity branding" do
    organisation = create(:organisation, organisation_logo_type_id: OrganisationLogoType::NoIdentity.id)
    get :show, id: organisation
    assert_select ".organisation-logo-stacked-no-identity"
  end

  test "#show includes the parent organisation branding on a sub-organisation" do
    organisation = create(:organisation, logo_formatted_name: "Ministry of Jam")
    sub_organisation = create(:sub_organisation, name: "Marmalade Inspection Board", parent_organisations: [organisation])

    get :show, id: sub_organisation

    assert_select ".page-header .organisation-logo", "Ministry of Jam"
    assert_select ".page-header .sub-organisation-name", "Marmalade Inspection Board"
  end

  test "shows primary featured editions in ordering defined by association" do
    organisation = create(:organisation)
    news_article = create(:published_news_article)
    policy = create(:published_policy)
    create(:featured_edition_organisation, edition: news_article, organisation: organisation, ordering: 1)
    create(:featured_edition_organisation, edition: policy, organisation: organisation, ordering: 0)

    get :show, id: organisation

    assert_equal [policy, news_article], assigns(:featured_editions).collect(&:model)
  end

  test "shows a maximum of 6 featured editions" do
    organisation = create(:organisation)
    editions = []
    7.times do |i|
      edition = create(:published_news_article, published_at: i.days.ago)
      editions << create(:featured_edition_organisation, edition: edition, organisation: organisation)
    end

    get :show, id: organisation

    assert_select_object editions[0].edition do
      assert_select "img[src$='#{editions[0].image.file.url(:s630)}'][alt=?]", editions[0].alt_text
    end
    editions[1...6].each do |edition|
      assert_select_object edition.edition do
        assert_select "img[src$='#{edition.image.file.url(:s300)}'][alt=?]", edition.alt_text
      end
    end
    refute_select_object editions.last.edition
  end

  test "should not display an empty featured editions section" do
    organisation = create(:organisation)
    get :show, id: organisation
    refute_select "#featured-documents article"
  end

  test "showing a live organisation renders the show template" do
    organisation = create(:organisation, govuk_status: 'live')

    get :show, id: organisation

    assert_template 'show'
  end

  test "showing a joining organisation renders the external template" do
    organisation = create(:organisation, govuk_status: 'joining')

    get :show, id: organisation

    assert_template 'external'
  end

  test "showing an exempt organisation renders the external template" do
    organisation = create(:organisation, govuk_status: 'exempt')

    get :show, id: organisation

    assert_template 'external'
  end

  test "showing an transitioning organisation renders the external template" do
    organisation = create(:organisation, govuk_status: 'transitioning')

    get :show, id: organisation

    assert_template 'external'
  end

  test "shows a link and thumbnail link of the organisation site when joining" do
    organisation = create(:organisation, govuk_status: 'joining', url: 'http://example.com')

    get :show, id: organisation

    assert_select ".description a[href=?]", organisation.url
    assert_select ".thumbnail" do
      assert_select "a[href=?]", organisation.url do
        assert_select "img[src$=?]", "#{organisation.slug}.png"
      end
    end
  end

  test "shows a link and thumbnail link of the organisation site when exempt" do
    organisation = create(:organisation, govuk_status: 'exempt', url: 'http://example.com')

    get :show, id: organisation

    assert_select ".description a[href=?]", organisation.url
    assert_select ".thumbnail" do
      assert_select "a[href=?]", organisation.url do
        assert_select "img[src$=?]", "#{organisation.slug}.png"
      end
    end
  end

  test "doesn't show a thumbnail if the organisation has no url" do
    organisation = create(:organisation, govuk_status: 'exempt', url: '')

    get :show, id: organisation

    assert_select ".description a[href=?]", organisation.url
    assert_select ".thumbnail", false
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

  test "should display link to policies filter if there are many policies" do
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

  test "should not display an empty topics section" do
    organisation = create(:organisation)
    get :show, id: organisation
    assert_select "#topics", count: 0
  end

  test "should display the organisation's policies with content" do
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
    assert_equal [policy_1, policy_2, policy_3], assigns[:policies]
  end

  test "should display the organisation's publications with content" do
    organisation = create(:organisation)
    publication = create(:published_publication, organisations: [organisation], publication_type: PublicationType::PolicyPaper, publication_date: Date.parse("2012-01-01"))
    consultation = create(:published_consultation, organisations: [organisation], opening_on: 3.days.ago)

    get :show, id: organisation

    assert_select "#publications" do
      assert_select_object publication do
        assert_select '.publication-date abbr[title=?]', Date.parse("2012-01-01").iso8601
        assert_select '.document-type', "Policy paper"
      end
      assert_select_object consultation do
        assert_select '.publication-date abbr[title=?]', 3.days.ago.iso8601
        assert_select '.document-type', "Open consultation"
      end
    end
  end

  test "should display organisation's latest three publications" do
    organisation = create(:organisation)
    publication_2 = create(:published_publication, organisations: [organisation], publication_date: 2.days.ago)
    publication_4 = create(:published_publication, organisations: [organisation], publication_date: 4.days.ago)
    publication_3 = create(:published_publication, organisations: [organisation], publication_date: 3.days.ago)
    publication_1 = create(:published_publication, organisations: [organisation], publication_date: 1.day.ago)
    get :show, id: organisation
    assert_equal [publication_1, publication_2, publication_3], assigns[:publications]
  end

  test "should display announcements in reverse chronological order" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    announcement_1 = create(:published_news_article, organisations: [organisation], published_at: 2.days.ago)
    announcement_2 = create(:published_speech, role_appointment: role_appointment, delivered_on: 3.days.ago)
    announcement_3 = create(:published_news_article, organisations: [organisation], published_at: 4.days.ago)
    announcement_4 = create(:published_news_article, organisations: [organisation], published_at: 1.days.ago)

    get :show, id: organisation

    assert_equal [announcement_4, announcement_1, announcement_2], assigns[:announcements]
  end

  test "should display 3 announcements with a link to announcements filter if there are many announcements" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    announcement_1 = create(:published_news_article, organisations: [organisation], published_at: 1.days.ago)
    announcement_2 = create(:published_speech, role_appointment: role_appointment, delivered_on: 2.days.ago)
    announcement_3 = create(:published_news_article, organisations: [organisation], published_at: 3.days.ago)
    announcement_4 = create(:published_news_article, organisations: [organisation], published_at: 4.days.ago)

    get :show, id: organisation

    assert_select '#announcements' do
      assert_select_object(announcement_1)
      assert_select_object(announcement_2)
      assert_select_object(announcement_3)
      refute_select_object(announcement_4)
      assert_select "a[href='#{announcements_filter_path(organisation)}']"
    end
  end

  test "should display the date on which a speech was delivered and its announcement type" do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    delivered_on = Date.parse("1999-12-31")
    speech = create(:published_speech, role_appointment: role_appointment, delivered_on: delivered_on, speech_type: SpeechType::WrittenStatement)

    get :show, id: organisation

    assert_select_object(speech) do
      assert_select "abbr.delivered_on[title=?]", delivered_on.iso8601
      assert_select ".announcement-type", "Statement to parliament"
    end
  end

  test "should display when a news article was first published and its announcement type" do
    first_published_at = Time.zone.parse("2001-01-01 01:01")
    organisation = create(:organisation)
    news_article = create(:published_news_article, organisations: [organisation], published_at: first_published_at)

    get :show, id: organisation

    assert_select_object(news_article) do
      assert_select "abbr.first_published_at[title=?]", first_published_at.iso8601
      assert_select ".announcement-type", "News article"
    end
  end

  test "presents the contact details of the organisation using hcard" do
    ministerial_department = create(:organisation_type, name: "Ministerial Department")
    organisation = create(:organisation, organisation_type: ministerial_department,
      name: "Ministry of Pomp", contacts_attributes: [{
        description: "Main",
        email: "pomp@gov.uk",
        contact_form_url: "http://pomp.gov.uk/contact",
        address: "1 Smashing Place, London", postcode: "LO1 8DN",
        contact_numbers_attributes: [
          { label: "Helpline", number: "02079460000" },
          { label: "Fax", number: "02079460001" }
        ]
      }]
    )
    get :show, id: organisation

    assert_select ".vcard" do
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
      assert_select ".contact_form_url" do
        assert_select "a[href=http://pomp.gov.uk/contact]"
      end
    end
  end

  test "should display sub-organisations" do
    organisation = create(:organisation)
    sub_organisation = create(:sub_organisation, parent_organisations: [organisation])

    get :show, id: organisation

    assert_select ".sub_organisations" do
      assert_select_object(sub_organisation)
    end
  end

  test 'show has atom feed autodiscovery link' do
    organisation = create(:organisation)

    get :show, id: organisation

    assert_select_autodiscovery_link organisation_url(organisation, format: "atom")
  end

  test 'show includes a link to the atom feed' do
    organisation = create(:organisation)

    get :show, id: organisation

    assert_select "a.feed[href=?]", organisation_url(organisation, format: :atom)
  end

  test "show generates an atom feed with entries for latest activity" do
    organisation = create(:organisation, name: "org-name")
    pub = create(:published_publication, organisations: [organisation], publication_date: 4.weeks.ago)
    pol = create(:published_policy, organisations: [organisation], publication_date: 2.weeks.ago)

    get :show, id: organisation, format: :atom

    assert_select_atom_feed do
      assert_select 'feed > entry', count: 2 do |entries|
        entries.zip([pol, pub]).each do |entry, document|
          assert_select entry, 'entry > id', 1
          assert_select entry, 'entry > published', count: 1, text: document.timestamp_for_sorting.iso8601
          assert_select entry, 'entry > updated', count: 1, text: document.timestamp_for_update.iso8601
          assert_select entry, 'entry > link[rel=?][type=?][href=?]', 'alternate', 'text/html', public_document_url(document)
          assert_select entry, 'entry > title', count: 1, text: document.title
          assert_select entry, 'entry > summary', count: 1, text: document.summary
          assert_select entry, 'entry > category', count: 1, text: document.display_type
          assert_select entry, 'entry > content[type=?]', 'html', count: 1, text: /#{document.body}/
        end
      end
    end
  end

  test "show generates an atom feed with summary and prefixed titles in entries for latest activity when govdelivery version is requested" do
    organisation = create(:organisation, name: "org-name")
    pub = create(:published_publication, organisations: [organisation], publication_date: 4.weeks.ago)
    pol = create(:published_policy, organisations: [organisation], publication_date: 2.weeks.ago)

    get :show, id: organisation, format: :atom, govdelivery_version: 'true'

    assert_select_atom_feed do
      assert_select 'feed > entry', count: 2 do |entries|
        entries.zip([pol, pub]).each do |entry, document|
          assert_select entry, 'entry > id', 1
          assert_select entry, 'entry > published', count: 1, text: document.timestamp_for_sorting.iso8601
          assert_select entry, 'entry > updated', count: 1, text: document.timestamp_for_update.iso8601
          assert_select entry, 'entry > link[rel=?][type=?][href=?]', 'alternate', 'text/html', public_document_url(document)
          assert_select entry, 'entry > title', count: 1, text: "#{document.display_type}: #{document.title}"
          assert_select entry, 'entry > summary', count: 1, text: document.summary
          assert_select entry, 'entry > category', count: 1, text: document.display_type
          assert_select entry, 'entry > content[type=?]', 'text', count: 1, text: document.summary
        end
      end
    end
  end

  test "should show description on organisation about subpage" do
    organisation = create(:organisation, description: "organisation-description")
    get :about, id: organisation
    assert_select ".description", text: "organisation-description"
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

  test "should display link to corporate information pages on about-us page" do
    organisation = create(:organisation)
    corporate_information_page = create(:corporate_information_page, organisation: organisation)
    get :about, id: organisation
    assert_select "a[href='#{organisation_corporate_information_page_path(organisation, corporate_information_page)}']"
  end

  test "should not display corporate information section on about-us page if there are no corporate publications" do
    organisation = create(:organisation)
    get :about, id: organisation
    refute_select "#corporate-information"
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

  test "shows military roles in the specified order" do
    junior_role = create(:military_role, role_appointments: [create(:role_appointment)])
    senior_role = create(:military_role, role_appointments: [create(:role_appointment)])
    organisation = create(:organisation)
    create(:organisation_role, organisation: organisation, role: junior_role, ordering: 2)
    create(:organisation_role, organisation: organisation, role: senior_role, ordering: 1)

    get :show, id: organisation

    assert_equal [senior_role, junior_role], assigns(:military_roles).collect(&:model)
  end

  test "shows links to ministers people pages" do
    minister = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, role: minister, person: person)
    organisation = create(:organisation, ministerial_roles: [minister])

    get :show, id: organisation

    assert_select_object person do
      assert_select "a[href=?]", person_path(person), text: person.name
    end
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

  test "should display the minister's picture if available" do
    ministerial_role = create(:ministerial_role)
    person = create(:person, image: File.open(File.join(Rails.root, 'test', 'fixtures', 'minister-of-funk.960x640.jpg')))
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create(:organisation, ministerial_roles: [ministerial_role])
    get :show, id: organisation
    assert_select "img[src*=minister-of-funk.960x640.jpg]"
  end

  test "should display a generic image if the minister doesn't have their own picture" do
    ministerial_role = create(:ministerial_role)
    person = create(:person)
    create(:role_appointment, person: person, role: ministerial_role)
    organisation = create(:organisation, ministerial_roles: [ministerial_role])
    get :show, id: organisation
    assert_select "img[src*=blank-person.png]"
  end

  test "shows management team members with links to person pages" do
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

  test "should not display an empty management team section" do
    organisation = create(:organisation, management_roles: [])

    get :show, id: organisation

    refute_select management_selector
  end

  test "shows special representatives with links to person pages" do
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

  test "should not display an empty special representatives section" do
    organisation = create(:organisation, special_representative_roles: [])

    get :show, id: organisation

    refute_select special_representative_selector
  end

  test "should place organisation specific css class on every organisation sub page" do
    ministerial_department = create(:organisation_type, name: "Ministerial Department")
    organisation = create(:organisation, organisation_type: ministerial_department)

    [:show, :about].each do |page|
      get page, id: organisation
      assert_select "##{dom_id(organisation)}.#{organisation.slug}.ministerial-department"
    end
  end

  test "shows 3 most recently published editions associated with organisation" do
    # different edition types sort on different attributes
    editions = [create(:published_policy, first_published_at: 1.days.ago),
               create(:published_publication, publication_date: 2.days.ago),
               create(:published_consultation, first_published_at: 3.days.ago),
               create(:published_speech, delivered_on: 4.days.ago)]

    organisation = create(:organisation, editions: editions)
    get :show, id: organisation

    assert_select ".latest-documents h1", "Latest"
    editions[0,3].each do |edition|
      assert_select_prefix_object edition, :recent
    end
    refute_select_prefix_object editions[3], :recent
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

    assert_select_object twitter_account
    assert_select_object flickr_account
  end

  test "should not show list of links to social media accounts if there are none" do
    organisation = create(:organisation, social_media_accounts: [])

    get :show, id: organisation

    refute_select ".social-media-accounts"
  end

  test "should show mainstream category links if there are some" do
    organisation = create(:organisation)
    link = create(:organisation_mainstream_link, organisation: organisation)

    get :show, id: organisation

    assert_select '.organisation-mainstream-links' do
      assert_select "a[href='#{link.url}']", text: link.title
    end
  end

  test "should not show mainstream categories on suborg pages" do
    organisation = create(:organisation)
    link = create(:organisation_mainstream_link, organisation: organisation)
    sub_organisation = create(:sub_organisation, parent_organisations: [organisation])

    get :show, id: sub_organisation

    refute_select "a[href='#{link.url}']", text: link.title
  end

  private

  def assert_disclaimer_present(organisation)
    assert_select "#organisation_disclaimer" do
      assert_select "a[href='#{organisation.url}']"
    end
  end
end
