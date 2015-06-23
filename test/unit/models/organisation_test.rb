require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  should_protect_against_xss_and_content_attacks_on :name

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

  test 'should be invalid if a custom logo is used with an exempt organisation' do
    assert build(:organisation, govuk_status: 'exempt', organisation_logo_type: OrganisationLogoType::NoIdentity).valid?
    refute build(:organisation, govuk_status: 'exempt', organisation_logo_type: OrganisationLogoType::CustomLogo).valid?
  end

  test 'should be valid if govuk status is transitioning' do
    new_organisation = build(:organisation, govuk_status: 'transitioning')
    assert new_organisation.valid?
  end

  test 'should be invalid if govuk status is closed and has no govuk closed status' do
    new_organisation = build(:organisation, govuk_status: 'closed')
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk status is closed and has an invalid govuk closed status' do
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'not-known-status')
    refute new_organisation.valid?
  end

  test 'should be valid if govuk status is closed and has a valid govuk closed status' do
    new_organisation = build(:closed_organisation)
    assert new_organisation.valid?
  end

  test 'should be invalid if govuk status is not active, coming, exempt or transitioning' do
    new_organisation = build(:organisation, govuk_status: 'something-elese')
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is merged and it has no superseding organisations' do
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'merged', superseding_organisations: [])
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is merged and it has more than one superseding organisation' do
    organisation_1 = create(:organisation, name: 'Superseding 1')
    organisation_2 = create(:organisation, name: 'Superseding 2')
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'merged', superseding_organisations: [organisation_1, organisation_2])
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is replaced and it has no superseding organisations' do
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'replaced', superseding_organisations: [])
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is replaced and it has more than one superseding organisation' do
    organisation_1 = create(:organisation, name: 'Superseding 1')
    organisation_2 = create(:organisation, name: 'Superseding 2')
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'replaced', superseding_organisations: [organisation_1, organisation_2])
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is name changed and it has no superseding organisations' do
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'changed_name', superseding_organisations: [])
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is name changed and it has more than one superseding organisation' do
    organisation_1 = create(:organisation)
    organisation_2 = create(:organisation)
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'changed_name', superseding_organisations: [organisation_1, organisation_2])
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is split and it has less than two superseding organisations' do
    organisation_1 = create(:organisation)
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'split', superseding_organisations: [organisation_1])
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is devolved and it has no superseding organisations' do
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'devolved', superseding_organisations: [])
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is devolved and it has more than one superseding organisation' do
    organisation_1 = create(:organisation, name: 'Superseding 1')
    organisation_2 = create(:organisation, name: 'Superseding 2')
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'devolved', superseding_organisations: [organisation_1, organisation_2])
    refute new_organisation.valid?
  end

  test 'should be invalid if govuk closed status is devolved and its superseding organisation is not devolved' do
    organisation_1 = create(:organisation)
    new_organisation = build(:organisation, govuk_status: 'closed', govuk_closed_status: 'devolved', superseding_organisations: [organisation_1])
    refute new_organisation.valid?
  end

  test 'should be invalid with a blank alternative_format_contact_email if it is used as a alternative_format_provider' do
    organisation = create(:organisation, alternative_format_contact_email: "alternative@example.com")
    create(:draft_publication, alternative_format_provider: organisation)
    assert organisation.valid?
    organisation.alternative_format_contact_email = ""
    refute organisation.valid?
  end

  test 'should be valid with a blank alternative_format_contact_email if the org is closed' do
    organisation = create(:closed_organisation, alternative_format_contact_email: "alternative@example.com")
    create(:draft_publication, alternative_format_provider: organisation)
    assert organisation.valid?
    organisation.alternative_format_contact_email = ""
    assert organisation.valid?
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

  test 'should be invalid if custom logo type selected but no logo present' do
    organisation = build(
      :organisation,
      organisation_logo_type_id: OrganisationLogoType::CustomLogo.id
    )
    refute organisation.valid?
    assert organisation.errors[:logo].present?
  end

  test 'can have a default news article image' do
    image = build(:default_news_organisation_image_data)
    organisation = build(:organisation, default_news_image: image)
    assert_equal image, organisation.default_news_image
  end

  test "should be orderable ignoring common prefixes" do
    hair = create(:organisation, name: "The Department for Hair")
    eyes = create(:organisation, name: "Eyes")
    wool = create(:organisation, name: "Department for Wool")

    assert_equal [hair, wool, eyes], Organisation.ordered_by_name_ignoring_prefix
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

  test '#has_child_organisation returns true if argument is a child of self' do
    child_org = create(:organisation)
    parent_org = create(:organisation, child_organisations: [child_org])

    assert parent_org.has_child_organisation?(child_org)
    refute child_org.has_child_organisation?(parent_org)
  end

  test "considers itself as superseded_by_devolved_administration if it's devolved and any of its superseding organisations are devolved administrations" do
    devolved_administration = build :devolved_administration
    other_organisation = build :organisation

    refute build(:closed_organisation, govuk_closed_status: 'devolved', superseding_organisations: [other_organisation]).superseded_by_devolved_administration?
    refute build(:closed_organisation, govuk_closed_status: 'no_longer_exists', superseding_organisations: [other_organisation, devolved_administration]).superseded_by_devolved_administration?
    assert build(:closed_organisation, govuk_closed_status: 'devolved', superseding_organisations: [other_organisation, devolved_administration]).superseded_by_devolved_administration?
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

  test '#chief_professional_officers includes all chief professional officers' do
    chief_professional_officer = create(:chief_professional_officer_role)
    organisation = create(:organisation, roles:  [chief_professional_officer])
    assert_equal [chief_professional_officer], organisation.chief_professional_officer_roles
  end

  test '#judge_roles includes only judges' do
    judge = create(:judge_role)
    chief_professional_officer = create(:chief_professional_officer_role)
    organisation = create(:organisation, roles:  [chief_professional_officer, judge])
    assert_equal [judge], organisation.judge_roles
  end

  test 'should be creatable with featured link data' do
    params = {
      featured_links_attributes: [
        {url: "https://www.gov.uk/blah/blah",
         title: "Blah blah"},
        {url: "https://www.gov.uk/wah/wah",
         title: "Wah wah"},
      ]
    }
    organisation = create(:organisation, params)

    links = organisation.featured_links
    assert_equal 2, links.count
    assert_equal "https://www.gov.uk/blah/blah", links[0].url
    assert_equal "Blah blah", links[0].title
    assert_equal "https://www.gov.uk/wah/wah", links[1].url
    assert_equal "Wah wah", links[1].title
  end

  test 'featured links are returned in order of creation' do
    organisation = create(:organisation)
    link_1 = create(:featured_link, linkable: organisation, title: '2 days ago', created_at: 2.days.ago)
    link_2 = create(:featured_link, linkable: organisation, title: '12 days ago', created_at: 12.days.ago)
    link_3 = create(:featured_link, linkable: organisation, title: '1 hour ago', created_at: 1.hour.ago)
    link_4 = create(:featured_link, linkable: organisation, title: '2 hours ago', created_at: 2.hours.ago)
    link_5 = create(:featured_link, linkable: organisation, title: '20 minutes ago', created_at: 20.minutes.ago)
    link_6 = create(:featured_link, linkable: organisation, title: '2 years ago', created_at: 2.years.ago)

    assert_equal [link_6, link_2, link_1, link_4, link_3, link_5], organisation.featured_links
    assert_equal [link_6, link_2, link_1, link_4, link_3], organisation.featured_links.only_the_initial_set
  end

  test 'should ignore blank featured link attributes' do
    params = {
      featured_links_attributes: [
        {url: "",
         title: ""}
      ]
    }
    organisation = build(:organisation, params)
    assert organisation.valid?
  end

  test "#visible_featurd_links_count should return the default number of links for news homepage type organisations" do
    organisation = build(:organisation)

    assert_equal FeaturedLink::DEFAULT_SET_SIZE, organisation.visible_featured_links_count
  end

  test "#visible_featurd_links_count should return 10 for service priority homepage type organisations" do
    organisation = build(:organisation, homepage_type: 'service')

    assert_equal 10, organisation.visible_featured_links_count
  end

  test "#visible_featured_links should return the correct number of featured links" do
    news_organisation = create(:organisation, homepage_type: 'news')
    6.times { create(:featured_link, linkable: news_organisation) }

    service_organisation = create(:organisation, homepage_type: 'service')
    11.times { create(:featured_link, linkable: service_organisation) }

    assert_equal 5, news_organisation.visible_featured_links.count
    assert_equal 10, service_organisation.visible_featured_links.count
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

  test 'should return search index data suitable for Rummageable' do
    organisation = create(:organisation, name: 'Ministry of Funk', acronym: 'MoF')

    assert_equal 'Ministry of Funk', organisation.search_index['title']
    assert_equal 'MoF', organisation.search_index['acronym']
    assert_equal "/government/organisations/#{organisation.slug}", organisation.search_index['link']
    assert_equal organisation.indexable_content, organisation.search_index['indexable_content']
    assert_equal 'organisation', organisation.search_index['format']
    assert_equal 'live', organisation.search_index['organisation_state']
  end

  test 'should add organisation to search index on creating' do
    organisation = build(:organisation)

    Whitehall::SearchIndex.expects(:add).with(organisation)

    organisation.save
  end

  test 'should add courts to index on creating' do
    hmcts = create(:organisation, slug: "hm-courts-and-tribunals-service", name: "HMCTS")

    court = build(:court, parent_organisations: [hmcts])
    Whitehall::SearchIndex.expects(:add).once.with(court)
    court.save
  end

  test 'should add HMCTS tribunals to index on creating' do
    hmcts = create(:organisation, slug: "hm-courts-and-tribunals-service", name: "HMCTS")

    hmcts_tribunal = build(:hmcts_tribunal, parent_organisations: [hmcts])
    Whitehall::SearchIndex.expects(:add).once.with(hmcts_tribunal)
    hmcts_tribunal.save
  end

  test 'should add organisation to search index on updating' do
    organisation = create(:organisation)

    Whitehall::SearchIndex.expects(:add).with(organisation)

    organisation.name = 'Ministry of Junk'
    organisation.save
  end

  test 'should add courts to index on updating' do
    court = create(:court)
    Whitehall::SearchIndex.expects(:add).with(court)
    court.name = "Junk Appeals Court"
    court.save
  end

  test 'should remove organisation from search index on destroying' do
    organisation = create(:organisation)
    Whitehall::SearchIndex.expects(:delete).with(organisation)
    organisation.destroy
  end

  test 'should remove courts from index on destroying' do
    court = create(:court)
    Whitehall::SearchIndex.expects(:delete).with(court)
    court.destroy
  end

  test 'should return search index data for all organisations' do
    about_type = CorporateInformationPageType.find('about')
    sport = create(:organisation, name: 'Department for Culture and Sports', govuk_status: 'closed', govuk_closed_status: 'no_longer_exists')
    create(:published_corporate_information_page, corporate_information_page_type: about_type, summary: 'Sporty.', organisation: sport)
    ed = create(:organisation, name: 'Department of Education')
    create(:published_corporate_information_page, corporate_information_page_type: about_type, summary: 'Bookish.', organisation: ed)
    hmrc = create(:organisation, name: 'HMRC', acronym: 'hmrc')
    create(:published_corporate_information_page, corporate_information_page_type: about_type, summary: 'Taxing.', organisation: hmrc)
    mod = create(:organisation, name: 'Ministry of Defence', acronym: 'mod')
    create(:published_corporate_information_page, corporate_information_page_type: about_type, summary: 'Defensive.', organisation: mod)
    superseding_organisation = create(:devolved_administration, name: 'Devolved administration')
    create(:organisation, name: 'Devolved organisation', acronym: 'dev', govuk_status: 'closed', govuk_closed_status: 'devolved', superseding_organisations: [superseding_organisation])

    results = Organisation.search_index.to_a

    assert_equal 6, results.length
    assert_equal({'title' => 'Department for Culture and Sports',
                  'link' => '/government/organisations/department-for-culture-and-sports',
                  'slug' => 'department-for-culture-and-sports',
                  'indexable_content' => 'Sporty. Some stuff',
                  'format' => 'organisation',
                  'description' => 'Sporty.',
                  'organisation_state' => 'closed'}, results[0])
    assert_equal({'title' => 'Department of Education',
                  'link' => '/government/organisations/department-of-education',
                  'slug' => 'department-of-education',
                  'indexable_content' => 'Bookish. Some stuff',
                  'format' => 'organisation',
                  'description' => 'Bookish.',
                  'organisation_state' => 'live'}, results[1])
    assert_equal({'title' => 'HMRC',
                  'acronym' => 'hmrc',
                  'link' => '/government/organisations/hmrc',
                  'slug' => 'hmrc',
                  'indexable_content' => 'Taxing. Some stuff',
                  'format' => 'organisation',
                  'boost_phrases' => 'hmrc',
                  'description' => 'Taxing.',
                  'organisation_state' => 'live'}, results[2])
    assert_equal({'title' => 'Ministry of Defence',
                  'acronym' => 'mod',
                  'link' => '/government/organisations/ministry-of-defence',
                  'slug' => 'ministry-of-defence',
                  'indexable_content' => 'Defensive. Some stuff',
                  'format' => 'organisation',
                  'boost_phrases' => 'mod',
                  'description' => 'Defensive.',
                  'organisation_state' => 'live'}, results[3])
    assert_equal({'title' => 'Devolved organisation',
                  'acronym' => 'dev',
                  'link' => '/government/organisations/devolved-organisation',
                  'slug' => 'devolved-organisation',
                  'indexable_content' => '',
                  'format' => 'organisation',
                  'boost_phrases' => 'dev',
                  'organisation_state' => 'devolved'}, results[5])
  end

  test '#published_announcements returns published news or speeches' do
    organisation = create(:organisation)
    create(:draft_speech, organisations: [organisation], title: "One")
    create(:draft_news_article, organisations: [organisation], title: "Two")
    create(:published_consultation, organisations: [organisation], title: "Three")
    expected_documents = [
      create(:published_speech, organisations: [organisation], title: "Alpha"),
      create(:published_news_article, organisations: [organisation], title: "Beta")
    ]

    assert_same_elements expected_documents, organisation.published_announcements
  end

  test '#destroy removes parent relationships' do
    child = create(:organisation)
    parent = create(:organisation, child_organisations: [child])
    child.destroy
    assert_equal 0, OrganisationalRelationship.count
    assert parent.reload.child_organisations.empty?
  end

  test 'destroy removes edition relationships' do
    organisation = create(:organisation)
    edition = create(:published_publication, organisations: [organisation])
    organisation.destroy
    assert_equal 0, EditionOrganisation.count
  end

  test 'destroy removes policy area relationships' do
    organisation = create(:organisation)
    topic = create(:topic)
    topic.organisations << organisation
    organisation.destroy
    assert_equal 0, OrganisationClassification.count
  end

  test 'destroy removes mainstream category relationships' do
    organisation = create(:organisation)
    mainstream_category = create(:mainstream_category)
    relationship =  create(:organisation_mainstream_category, organisation: organisation, mainstream_category: mainstream_category)
    organisation.destroy
    refute OrganisationMainstreamCategory.exists?(relationship.id)
  end

  test 'destroy unsets user organisation' do
    organisation = create(:organisation)
    user = create(:writer, organisation: organisation)
    organisation.destroy
    assert_nil user.reload.organisation_slug
  end

  test 'destroys associated corporate information page documents and editions' do
    organisation = create(:corporate_information_page).organisation
    assert_difference %w(Organisation.count Document.count CorporateInformationPage.count), -1 do
      organisation.destroy
    end
  end

  test 'should use full name as display_name if acronym is an empty string' do
    assert_equal 'Blah blah', build(:organisation, acronym: '', name: 'Blah blah').display_name
  end

  test 'select_name should use full name and acronym if present or not if not' do
    assert_equal 'Name (Blah)', build(:organisation, acronym: 'Blah', name: 'Name').select_name
    assert_equal 'Name', build(:organisation, acronym: '', name: 'Name').select_name
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
    t = create(:corporate_information_page, corporate_information_page_type: types.pop, organisation: organisation)
    organisation.reload
    assert_equal types, organisation.unused_corporate_information_page_types
  end

  test "can get a corporate information page with a particular slug" do
    organisation = create(:organisation)
    tor = create(:corporate_information_page, corporate_information_page_type: CorporateInformationPageType::TermsOfReference, organisation: organisation)
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
    assert_raise ActiveRecord::RecordNotFound do
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
    organisation = build(:organisation, analytics_identifier: "FOO123")
    organisation.save!
    assert_equal "FOO123", organisation.reload.analytics_identifier
  end

  test "policy areas are explicitly ordered" do
    topics = [create(:topic), create(:topic)]
    organisation = create(:organisation)
    organisation.organisation_classifications.create(classification_id: topics[0].id, ordering: 2)
    organisation.organisation_classifications.create(classification_id: topics[1].id, ordering: 1)
    assert_match /order by/i, organisation.topics.to_sql
    assert_equal [topics[1], topics[0]], organisation.topics
  end

  test "mainstream categories are explicitly ordered" do
    mainstream_categories = [create(:mainstream_category), create(:mainstream_category)]
    organisation = create(:organisation)
    organisation.organisation_mainstream_categories.create(mainstream_category_id: mainstream_categories[0].id, ordering: 2)
    organisation.organisation_mainstream_categories.create(mainstream_category_id: mainstream_categories[1].id, ordering: 1)
    assert_match /order by/i, organisation.mainstream_categories.to_sql
    assert_equal [mainstream_categories[1], mainstream_categories[0]], organisation.mainstream_categories
  end

  test "can have associated contacts" do
    organisation = create(:organisation)
    contact = organisation.contacts.create(title: "Main office")
  end

  test 'destroy deletes related contacts' do
    organisation = create(:organisation)
    contact = create(:contact, contactable: organisation)
    organisation.destroy
    assert_nil Contact.find_by(id: contact.id)
  end

  test "can have associated social media accounts" do
    service = create(:social_media_service)
    organisation = create(:organisation)
    contact = organisation.social_media_accounts.create(social_media_service_id: service.id, url: "http://example.com")
  end

  test 'destroy deletes related social media accounts' do
    organisation = create(:organisation)
    social_media_account = create(:social_media_account, socialable: organisation)
    organisation.destroy
    assert_nil SocialMediaAccount.find_by(id: social_media_account.id)
  end

  test "can sponsor worldwide offices" do
    organisation = create(:organisation)
    world_organisation = create(:worldwide_organisation)
    organisation.sponsored_worldwide_organisations << world_organisation

    assert_equal [world_organisation], organisation.reload.sponsored_worldwide_organisations
  end

  test "destroy deletes sponsorships" do
    organisation = create(:organisation, sponsored_worldwide_organisations: [create(:worldwide_organisation)])
    organisation.destroy

    assert_equal 0, organisation.sponsorships.count
  end

  test 'can provide a list of all its FOI contacts' do
    organisation = create(:organisation)
    contact_1 = create(:contact, contactable: organisation, contact_type: ContactType::FOI)
    contact_2 = create(:contact, contact_type: ContactType::FOI)
    contact_3 = create(:contact, contactable: organisation, contact_type: ContactType::Media)
    contact_4 = create(:contact, contactable: organisation, contact_type: ContactType::General)

    foi_contacts = organisation.foi_contacts
    assert foi_contacts.include?(contact_1), 'expected our foi contact to be in our list of foi contacts'
    refute foi_contacts.include?(contact_2), 'expected someone else\'s foi contact not to be in our list of foi contacts'
    refute foi_contacts.include?(contact_3), 'expected our media contact not to be in our list of foi contacts'
    refute foi_contacts.include?(contact_4), 'expected our general contact not to be in our list of foi contacts'
  end

  test 'knows if a given contact is on its home page' do
    organisation = build(:organisation)
    c = build(:contact)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:shown_on_home_page?).with(c).returns :the_answer

    assert_equal :the_answer, organisation.contact_shown_on_home_page?(c)
  end

  test 'knows that its FOI contacts are on the home page, even if it\'s not explicitly in the list' do
    organisation = create(:organisation)
    contact_1 = create(:contact, contactable: organisation, contact_type: ContactType::FOI)
    contact_2 = create(:contact, contact_type: ContactType::FOI)

    assert organisation.contact_shown_on_home_page?(contact_1), 'expected FOI contact that belongs to org to be shown_on_home_page?, but it wasn\'t'
    refute organisation.contact_shown_on_home_page?(contact_2), 'expected FOI contact that doesn\'t belong to org to not be shown_on_home_page?, but it was'
  end

  test 'has a list of contacts that are on its home page' do
    organisation = build(:organisation)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    c = build(:contact)
    h.expects(:items).returns [c]

    assert_equal [c], organisation.home_page_contacts
  end

  test 'the list of contacts that are on its home page excludes any FOI contacts' do
    organisation = create(:organisation)
    contact_1 = create(:contact, contactable: organisation, contact_type: ContactType::General)
    contact_2 = create(:contact, contactable: organisation, contact_type: ContactType::FOI)
    contact_3 = create(:contact, contactable: organisation, contact_type: ContactType::Media)
    organisation.add_contact_to_home_page!(contact_1)
    organisation.add_contact_to_home_page!(contact_2)
    organisation.add_contact_to_home_page!(contact_3)

    assert_equal [contact_1, contact_3], organisation.home_page_contacts
  end

  test 'can add a contact to the list of those that are on its home page' do
    organisation = build(:organisation)
    c = build(:contact)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:add_item).with(c).returns :a_result

    assert_equal :a_result, organisation.add_contact_to_home_page!(c)
  end

  test 'can remove a contact from the list of those that are on its home page' do
    organisation = build(:organisation)
    c = build(:contact)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:remove_item).with(c).returns :a_result

    assert_equal :a_result, organisation.remove_contact_from_home_page!(c)
  end

  test 'can reorder the contacts on the list' do
    organisation = build(:organisation)
    c1 = create(:contact)
    c2 = create(:contact)
    h = build(:home_page_list)
    HomePageList.stubs(:get).returns(h)
    h.expects(:reorder_items!).with([c1, c2]).returns :a_result

    assert_equal :a_result, organisation.reorder_contacts_on_home_page!([c1, c2])
  end

  test 'maintains a home page list for storing contacts' do
    organisation = build(:organisation)
    HomePageList.expects(:get).with(has_entries(owned_by: organisation, called: 'contacts')).returns :a_home_page_list_of_contacts
    assert_equal :a_home_page_list_of_contacts, organisation.__send__(:home_page_contacts_list)
  end

  test 'when destroyed, will remove its home page list for storing contacts' do
    organisation = create(:organisation)
    h = organisation.__send__(:home_page_contacts_list)
    organisation.destroy
    refute HomePageList.exists?(h.id)
  end

  test 'Organisation.with_published_editions returns organisations with published editions' do
    org1 = create(:organisation)
    org2 = create(:organisation)
    org3 = create(:organisation)
    org4 = create(:organisation)

    create(:published_news_article, organisations: [org1])
    create(:published_publication, organisations: [org3])

    assert_same_elements [org1, org3], Organisation.with_published_editions
  end

  test '#organisation_brand_colour fetches the brand colour' do
    org = create(:organisation, organisation_brand_colour_id: 1)
    assert_equal org.organisation_brand_colour, OrganisationBrandColour::AttorneyGeneralsOffice
  end

  test '#organisation_brand_colour= sets the brand colour' do
    org = create(:organisation)
    org.organisation_brand_colour = OrganisationBrandColour::AttorneyGeneralsOffice
    assert_equal org.organisation_brand_colour_id, 1
  end

  test "excluding_govuk_status_closed scopes to all organisations which don't have a govuk_state of 'closed'" do
    open_org = create(:organisation, govuk_status: 'live')
    closed_org = create(:closed_organisation)
    assert_equal [open_org], Organisation.excluding_govuk_status_closed
  end
  test "closed scopes to organisations which have a govuk_state of 'closed'" do
    open_org = create(:organisation, govuk_status: 'live')
    closed_org = create(:closed_organisation)
    assert_equal [closed_org], Organisation.closed
  end

  test "with_statistics_announcements scopes to organisations with associated statistics_announcements" do
    org_with_announcement = create(:organisation)
    create(:statistics_announcement, organisation_ids: [org_with_announcement.id])
    org_without_announcement = create(:organisation)
    assert_equal [org_with_announcement], Organisation.with_statistics_announcements
  end

  test "#has_services_and_information_link? returns true if slug is in the whitelist" do
    org = create(:organisation)

    list = [
      org.slug
    ]
    org.stubs(:organisations_with_services_and_information_link).returns(list)

    assert org.has_services_and_information_link?
  end

  test "#has_services_and_information_link? returns false if slug is not in the whitelist" do
    list = [
      'a-slug'
    ]
    org = create(:organisation)
    org.stubs(:organisations_with_services_and_information_link).returns(list)

    refute org.has_services_and_information_link?
  end

  test '#jobs_url defaults to the default jobs url' do
    organisation = build(:organisation)
    assert_equal Organisation::DEFAULT_JOBS_URL, organisation.jobs_url
  end

  test '#jobs_url can be overridden' do
    organisation = build(:organisation, custom_jobs_url: 'http://jobs.com/')

    assert organisation.valid?
    assert_equal 'http://jobs.com/', organisation.jobs_url
  end

  test '#statistics_announcements returns all statistics_announcements associated with the organisation' do
    organisation = create(:organisation)
    statistics_announcement_organisations = create_list(:statistics_announcement, 2, organisation_ids: [organisation.id])

    assert_equal organisation.statistics_announcements, StatisticsAnnouncementOrganisation.all.map(&:statistics_announcement)
  end

  test "#service_priority_homepage? should be true if its homepage type is service" do
    organisation = build(:organisation, homepage_type: 'service')

    assert organisation.service_priority_homepage?
    refute organisation.news_priority_homepage?
  end

  test "#news_priority_homepage? should be true if its homepage type is news" do
    organisation = build(:organisation, homepage_type: 'news')

    assert organisation.news_priority_homepage?
    refute organisation.service_priority_homepage?
  end
end
