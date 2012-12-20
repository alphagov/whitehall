require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name, :about_us, :description

  test 'should be invalid without a name' do
    organisation = build(:organisation, name: nil)
    refute organisation.valid?
  end

  test 'should be invalid without a logo formatted name' do
    organisation = build(:organisation, logo_formatted_name: nil)
    refute organisation.valid?
  end

  test 'should be invalid with a duplicate name' do
    existing_organisation = create(:organisation)
    new_organisation = build(:organisation, name: existing_organisation.name)
    refute new_organisation.valid?
  end

  test 'should be invalid with a badly formatted alternative_format_contact_email' do
    new_organisation = build(:organisation, alternative_format_contact_email: "this@email@is@invalid")
    refute new_organisation.valid?
  end

  test 'should be valid if govuk status is live' do
    new_organisation = build(:organisation, govuk_status: 'live')
    assert new_organisation.valid?
  end

  test 'should be valid if govuk status is joining' do
    new_organisation = build(:organisation, govuk_status: 'joining')
    assert new_organisation.valid?
  end

  test 'should be valid if govuk status is exempt' do
    new_organisation = build(:organisation, govuk_status: 'exempt')
    assert new_organisation.valid?
  end

  test 'should be valid if govuk status is transitioning' do
    new_organisation = build(:organisation, govuk_status: 'transitioning')
    assert new_organisation.valid?
  end

  test 'should be invalid if govuk status is not active, coming, exempt or transitioning' do
    new_organisation = build(:organisation, govuk_status: 'something-elese')
    refute new_organisation.valid?
  end

  test 'should be invalid with a blank alternative_format_contact_email if it is used as a alternative_format_provider' do
    organisation = create(:organisation, alternative_format_contact_email: "alternative@example.com")
    create(:draft_publication, alternative_format_provider: organisation)
    assert organisation.valid?
    organisation.alternative_format_contact_email = ""
    refute organisation.valid?
  end

  test 'should be invalid with a URL that doesnt start with a protocol' do
    assert build(:organisation, url: nil).valid?
    assert build(:organisation, url: '').valid?
    refute build(:organisation, url: "blah").valid?
    refute build(:organisation, url: "www.example.com").valid?
    assert build(:organisation, url: "http://www.example.com").valid?
  end

  test 'should be invalid without a organisation logo type' do
    organisation = build(:organisation, organisation_logo_type: nil)
    refute organisation.valid?
  end

  test "should be orderable ignoring common prefixes" do
    culture = create(:organisation, name: "Department for Culture and Sports")
    education = create(:organisation, name: "Department of Education")
    hmrc = create(:organisation, name: "HMRC")
    defence = create(:organisation, name: "Ministry of Defence")

    assert_equal [culture, defence, education, hmrc], Organisation.ordered_by_name_ignoring_prefix
  end

  test "should be ordered by name by default" do
    b = create(:organisation, name: 'B')
    c = create(:organisation, name: 'C')
    a = create(:organisation, name: 'A')

    assert_equal [a, b, c], Organisation.all
  end

  test "#child_organisations should return the parent's children organisations" do
    parent_org_1 = create(:organisation)
    parent_org_2 = create(:organisation)
    child_org_1 = create(:organisation, parent_organisations: [parent_org_1])
    child_org_2 = create(:organisation, parent_organisations: [parent_org_1])
    child_org_3 = create(:organisation, parent_organisations: [parent_org_2])

    assert_equal [child_org_1, child_org_2], parent_org_1.child_organisations
  end

  test "#parent_organisations should return the child's parent organisations" do
    child_org_1 = create(:organisation)
    child_org_2 = create(:organisation)
    parent_org_1 = create(:organisation, child_organisations: [child_org_1])
    parent_org_2 = create(:organisation, child_organisations: [child_org_1])
    parent_org_3 = create(:organisation, child_organisations: [child_org_2])

    assert_equal [parent_org_1, parent_org_2], child_org_1.parent_organisations
  end

  test 'can list all parent organisations' do
    parent = create(:organisation, child_organisations: [create(:organisation)])

    assert_equal [parent.id], Organisation.parent_organisations.map(&:id)
  end

  test 'sub-organisations are not valid without a parent organisation' do
    sub_organisation = build(:sub_organisation, parent_organisations: [])
    refute sub_organisation.valid?, "Sub-organisations should not be valid without a parent"
    assert sub_organisation.errors.full_messages.include?("Parent organisations must not be empty for sub-organisations")
  end

  test 'can list its agencies and public bodies, i.e. all child organisations except sub-organisations' do
    parent_org_1 = create(:organisation)
    parent_org_2 = create(:organisation)
    child_org_1 = create(:organisation, parent_organisations: [parent_org_1])
    child_org_2 = create(:sub_organisation, parent_organisations: [parent_org_1])
    child_org_3 = create(:organisation, parent_organisations: [parent_org_1])

    assert_equal [child_org_1, child_org_3], parent_org_1.agencies_and_public_bodies
  end

  test 'can list its sub-organisations' do
    parent = create(:organisation)
    sub_organisation = create(:sub_organisation, parent_organisations: [parent])
    assert_equal [sub_organisation], parent.sub_organisations
  end

  test '#ministerial_roles includes all ministerial roles' do
    minister = create(:ministerial_role)
    organisation = create(:organisation, roles:  [minister])
    assert_equal [minister], organisation.ministerial_roles
  end

  test '#ministerial_roles excludes non-ministerial roles' do
    permanent_secretary = create(:board_member_role)
    organisation = create(:organisation, roles:  [permanent_secretary])
    assert_equal [], organisation.ministerial_roles
  end

  test "#traffic_commissioner_roles includes all traffic commissioner roles" do
    traffic_commissioner = create(:traffic_commissioner_role)
    organisation = create(:organisation, roles: [traffic_commissioner])
    assert_equal [traffic_commissioner], organisation.traffic_commissioner_roles
  end

  test "#traffic_commissioner_roles excludes all non traffic commissioner roles" do
    permanent_secretary = create(:board_member_role)
    organisation = create(:organisation, roles:  [permanent_secretary])
    assert_equal [], organisation.traffic_commissioner_roles
  end

  test '#management_roles includes all board member roles' do
    permanent_secretary = create(:board_member_role)
    organisation = create(:organisation, roles:  [permanent_secretary])
    assert_equal [permanent_secretary], organisation.management_roles
  end

  test '#management_roles excludes any ministerial roles' do
    minister = create(:ministerial_role)
    organisation = create(:organisation, roles:  [minister])
    assert_equal [], organisation.management_roles
  end

  test '#management_roles also includes chief scientific advisor roles' do
    chief_scientific_advisor = create(:chief_scientific_advisor_role)
    organisation = create(:organisation, roles:  [chief_scientific_advisor])
    assert_equal [chief_scientific_advisor], organisation.management_roles
  end

  test '#special_representative_roles includes all special representatives' do
    representative = create(:special_representative_role)
    organisation = create(:organisation, roles:  [representative])
    assert_equal [representative], organisation.special_representative_roles
  end

  test 'should be creatable with contact data' do
    params = {
      contacts_attributes: [
        {description: "Office address",
         email: "someone@gov.uk", address: "Aviation House, London",
         postcode: "WC2A 1BE", latitude: -0.112311, longitude: 51.215125},
        {description: "Helpline", contact_numbers_attributes: [
          {label: "Telephone", number: "020712345678"},
          {label: "Fax", number: "020712345679"}
        ]}
      ]
    }
    organisation = create(:organisation, params)

    assert_equal 2, organisation.contacts.count
    assert_equal "someone@gov.uk", organisation.contacts[0].email
    assert_equal "Aviation House, London", organisation.contacts[0].address
    assert_equal "WC2A 1BE", organisation.contacts[0].postcode
    assert_equal -0.112311, organisation.contacts[0].latitude
    assert_equal 51.215125, organisation.contacts[0].longitude
    assert_equal "Helpline", organisation.contacts[1].description
    assert_equal 2, organisation.contacts[1].contact_numbers.count
    assert_equal "Telephone", organisation.contacts[1].contact_numbers[0].label
    assert_equal "020712345678", organisation.contacts[1].contact_numbers[0].number
    assert_equal "Fax", organisation.contacts[1].contact_numbers[1].label
    assert_equal "020712345679", organisation.contacts[1].contact_numbers[1].number
  end

  test "should be creatable when both contacts and contact numbers are blank" do
    organisation = build(:organisation, contacts_attributes: [
      {description: "", contact_numbers_attributes: [{label: "", number: ""}]}
    ])
    assert organisation.valid?
  end

  test 'should be creatable with mainstream link data' do
    params = {
      organisation_mainstream_links_attributes: [
        {url: "https://www.gov.uk/blah/blah",
         title: "Blah blah"},
        {url: "https://www.gov.uk/wah/wah",
         title: "Wah wah"},
      ]
    }
    organisation = create(:organisation, params)

    links = organisation.organisation_mainstream_links
    assert_equal 2, links.count
    assert_equal "https://www.gov.uk/blah/blah", links[0].url
    assert_equal "Blah blah", links[0].title
    assert_equal "https://www.gov.uk/wah/wah", links[1].url
    assert_equal "Wah wah", links[1].title
  end

  test 'should ignore blank mainstream link attributes' do
    params = {
      organisation_mainstream_links_attributes: [
        {url: "",
         title: ""}
      ]
    }
    organisation = build(:organisation, params)
    assert organisation.valid?
  end

  test "should set a slug from the organisation name" do
    organisation = create(:organisation, name: 'Love all the people')
    assert_equal 'love-all-the-people', organisation.slug
  end

  test "should not change the slug when the name is changed" do
    organisation = create(:organisation, name: 'Love all the people')
    organisation.update_attributes(name: 'Hold hands')
    assert_equal 'love-all-the-people', organisation.slug
  end

  test "should not include apostrophes in slug" do
    organisation = create(:organisation, name: "Bob's bike")
    assert_equal 'bobs-bike', organisation.slug
  end

  test "should be returnable in an ordering suitable for organisational listing" do
    type_names = [
      "Ministerial department",
      "Non-ministerial department",
      "Executive agency",
      "Executive non-departmental public body",
      "Advisory non-departmental public body",
      "Tribunal non-departmental public body",
      "Public corporation",
      "Independent monitoring body",
      "Ad-hoc advisory group",
      "Other"
    ]
    types = type_names.shuffle.map { |t| create(:organisation_type, name: t) }
    organisations = types.shuffle.each { |t| create(:organisation, organisation_type: t) }

    orgs_in_order = Organisation.in_listing_order
    assert_equal type_names, orgs_in_order.map(&:organisation_type).map(&:name)
  end

  test 'should return search index data suitable for Rummageable' do
    organisation = create(:organisation, name: 'Ministry of Funk')

    assert_equal 'Ministry of Funk', organisation.search_index['title']
    assert_equal "/government/organisations/#{organisation.slug}", organisation.search_index['link']
    assert_equal organisation.description, organisation.search_index['indexable_content']
    assert_equal 'organisation', organisation.search_index['format']
  end

  test 'should add organisation to search index on creating' do
    organisation = build(:organisation)

    search_index_data = stub('search index data')
    organisation.stubs(:search_index).returns(search_index_data)
    Rummageable.stubs(:index) # ignore the update to the ministerial role index
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_name)

    organisation.save
  end

  test 'should add organisation to search index on updating' do
    organisation = create(:organisation)

    search_index_data = stub('search index data')
    organisation.stubs(:search_index).returns(search_index_data)
    Rummageable.stubs(:index) # ignore the update to the ministerial role index
    Rummageable.expects(:index).with(search_index_data, Whitehall.government_search_index_name)

    organisation.name = 'Ministry of Junk'
    organisation.save
  end

  test 'should remove organisation from search index on destroying' do
    organisation = create(:organisation)
    Rummageable.expects(:delete).with("/government/organisations/#{organisation.slug}", Whitehall.government_search_index_name)
    organisation.destroy
  end

  test 'should return search index data for all organisations' do
    create(:organisation, name: 'Department for Culture and Sports', description: 'Sporty.')
    create(:organisation, name: 'Department of Education', description: 'Bookish.')
    create(:organisation, name: 'HMRC', description: 'Taxing.', acronym: 'hmrc')
    create(:organisation, name: 'Ministry of Defence', description: 'Defensive.', acronym: 'mod')

    results = Organisation.search_index

    assert_equal 4, results.length
    assert_equal({'title' => 'Department for Culture and Sports',
                  'link' => '/government/organisations/department-for-culture-and-sports',
                  'indexable_content' => 'Sporty.',
                  'format' => 'organisation',
                  'description' => ''}, results[0])
    assert_equal({'title' => 'Department of Education',
                  'link' => '/government/organisations/department-of-education',
                  'indexable_content' => 'Bookish.',
                  'format' => 'organisation',
                  'description' => ''}, results[1])
    assert_equal({'title' => 'HMRC',
                  'link' => '/government/organisations/hmrc',
                  'indexable_content' => 'Taxing.',
                  'format' => 'organisation',
                  'boost_phrases' => 'hmrc',
                  'description' => ''}, results[2])
    assert_equal({'title' => 'Ministry of Defence',
                  'link' => '/government/organisations/ministry-of-defence',
                  'indexable_content' => 'Defensive.',
                  'format' => 'organisation',
                  'boost_phrases' => 'mod',
                  'description' => ''}, results[3])
  end

  test '#featured_editions returns featured editions by ordering' do
    organisation = create(:organisation)
    alpha = create(:edition_organisation, organisation: organisation, edition: create(:published_edition, title: "Alpha"))
    beta = create(:featured_edition_organisation, organisation: organisation, edition: create(:published_edition, title: "Beta"), ordering: 1)
    gamma = create(:featured_edition_organisation, organisation: organisation, edition: create(:published_edition, title: "Gamma"), ordering: 0)
    delta = create(:featured_edition_organisation, organisation: organisation, edition: create(:published_edition, title: "Delta"), ordering: 2)

    assert_equal [gamma.edition, beta.edition, delta.edition], organisation.featured_editions
  end

  test '#published_detailed_guides returns published detailed guides' do
    organisation = create(:organisation)
    alpha = create(:draft_detailed_guide, organisations: [organisation], title: "Alpha")
    beta = create(:published_detailed_guide, organisations: [organisation], title: "Beta")
    gamma = create(:published_detailed_guide, organisations: [organisation], title: "Gamma")
    delta = create(:published_detailed_guide, organisations: [organisation], title: "Delta")

    assert_same_elements [gamma, beta, delta], organisation.published_detailed_guides
  end

  test '#published_announcements returns published news or speeches' do
    organisation = create(:organisation)
    role = create(:ministerial_role, organisations: [organisation])
    role_appointment = create(:ministerial_role_appointment, role: role)
    create(:draft_speech, role_appointment: role_appointment, title: "One")
    create(:draft_news_article, organisations: [organisation], title: "Two")
    create(:published_consultation, organisations: [organisation], title: "Three")
    expected_documents = [
      create(:published_speech, role_appointment: role_appointment, title: "Alpha"),
      create(:published_news_article, organisations: [organisation], title: "Beta")
    ]

    assert_same_elements expected_documents, organisation.published_announcements
  end

  test "#published_policies returns published policies" do
    organisation = create(:organisation)
    one = create(:published_policy, organisations: [organisation], title: "One")
    two = create(:draft_policy, organisations: [organisation], title: "Two")
    three = create(:published_policy, organisations: [organisation], title: "Three")

    assert_same_elements [one, three], organisation.published_policies
  end

  test '#destroy removes parent relationships' do
    child = create(:organisation)
    parent = create(:organisation, child_organisations: [child])
    child.destroy
    assert_equal 0, OrganisationalRelationship.count
    assert parent.reload.child_organisations.empty?
  end

  test 'destroy deletes related contacts' do
    organisation = create(:organisation)
    contact = create(:contact, organisation: organisation)
    organisation.destroy
    assert_nil Contact.find_by_id(contact.id)
  end

  test 'destroy deletes related social media accounts' do
    organisation = create(:organisation)
    social_media_account = create(:social_media_account, socialable: organisation)
    organisation.destroy
    assert_nil SocialMediaAccount.find_by_id(social_media_account.id)
  end

  test 'destroy removes edition relationships' do
    organisation = create(:organisation)
    edition = create(:published_edition, organisations: [organisation])
    organisation.destroy
    assert_equal 0, EditionOrganisation.count
  end

  test 'destroy removes topic relationships' do
    organisation = create(:organisation)
    topic = create(:topic, organisations: [organisation])
    organisation.destroy
    assert_equal 0, OrganisationClassification.count
  end

  test 'destroy unsets user organisation' do
    organisation = create(:organisation)
    user = create(:policy_writer, organisation: organisation)
    organisation.destroy
    assert_nil user.reload.organisation_id
  end

  test 'should use full name as display_name if acronym is an empty string' do
    assert_equal 'Blah blah', build(:organisation, acronym: '', name: 'Blah blah').display_name
  end

  test "should be destroyable when there are no associated people/child orgs/roles" do
    organisation = create(:organisation)
    assert organisation.destroyable?
  end

  test "should not be destroyable if there are associated roles" do
    organisation = create(:organisation)
    role = create(:role)
    organisation.roles << role
    refute organisation.destroyable?
    organisation.destroy
    assert Organisation.find(organisation.id)
  end

  test "should not be destroyable if there are associated child orgs" do
    organisation = create(:organisation)
    child_org = create(:organisation)
    organisation.child_organisations << child_org
    refute organisation.destroyable?
    organisation.destroy
    assert Organisation.find(organisation.id)
  end

  test "should be able to list unused corporate information types" do
    organisation = create(:organisation)
    types = CorporateInformationPageType.all
    t = create(:corporate_information_page, type: types.pop, organisation: organisation)
    organisation.reload
    assert_equal types, organisation.unused_corporate_information_page_types
  end

  test "can get a corporate information page with a particular slug" do
    organisation = create(:organisation)
    tor = create(:corporate_information_page, type: CorporateInformationPageType::TermsOfReference, organisation: organisation)
    organisation.reload
    assert_equal tor, organisation.corporate_information_pages.for_slug(tor.slug)
  end

  test "#for_slug returns nil if the given page doesn't exist" do
    organisation = create(:organisation)
    tor = CorporateInformationPageType::TermsOfReference
    assert_nil organisation.corporate_information_pages.for_slug(tor.slug)
  end

  test "#for_slug! raises if the given page doesn't exist" do
    organisation = create(:organisation)
    tor = CorporateInformationPageType::TermsOfReference
    assert_raises ActiveRecord::RecordNotFound do
      organisation.corporate_information_pages.for_slug!(tor.slug)
    end
  end

  test "can report whether any published publications of a particular type are available" do
    organisation = create(:organisation)
    refute organisation.has_published_publications_of_type?(PublicationType::FoiRelease)
    create(:published_publication, :foi_release, organisations: [organisation])
    assert organisation.has_published_publications_of_type?(PublicationType::FoiRelease)
  end

  test "ensures that analytics identifier exists on save" do
    organisation = build(:organisation, analytics_identifier: nil)
    refute organisation.analytics_identifier.present?
    organisation.save!
    assert organisation.reload.analytics_identifier.present?
  end

  test "only sets analytics identifier if nil" do
    organisation = build(:organisation, analytics_identifier: "FOO123" )
    organisation.save!
    assert_equal "FOO123", organisation.reload.analytics_identifier
  end

  test "topics are explicitly ordered" do
    topics = [create(:topic), create(:topic)]
    organisation = create(:organisation)
    organisation.organisation_classifications.create(classification_id: topics[0].id, ordering: 2)
    organisation.organisation_classifications.create(classification_id: topics[1].id, ordering: 1)
    assert_match /order by/i, organisation.topics.to_sql
    assert_equal [topics[1], topics[0]], organisation.topics
  end
end
