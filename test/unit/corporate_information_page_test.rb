require "test_helper"

class CorporateInformationPageTest < ActiveSupport::TestCase
  def self.should_be_invalid_without(type, attribute_name)
    test "#{type} should be invalid without #{attribute_name}" do
      document = build(type, attribute_name => nil)
      assert_not document.valid?
    end
  end

  should_be_invalid_without(:corporate_information_page, :corporate_information_page_type)
  should_be_invalid_without(:corporate_information_page, :body)

  test 'AboutUs pages do not require a body' do
    corporate_information_page = build(:corporate_information_page,
                                       body: '',
                                       corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id)

    assert corporate_information_page.valid?
  end

  test 'should be invalid if has both organisation and worldwide org' do
    organisation = create(:organisation)
    worldwide_org = create(:worldwide_organisation)
    corporate_information_page = build(:corporate_information_page,
                                       organisation: organisation,
                                       worldwide_organisation: worldwide_org)
    assert_not corporate_information_page.valid?
  end

  test 'should be invalid if it refers to the same document of another page' do
    organisation = create(:organisation)
    corporate_information_page_1 = build(:corporate_information_page,
                                         organisation: organisation,
                                         corporate_information_page_type: CorporateInformationPageType::AboutUs,
                                         state: 'published',
                                         major_change_published_at: Time.zone.now)
    corporate_information_page_1.save!

    corporate_information_page_2 = build(:corporate_information_page,
                                         organisation: organisation,
                                         corporate_information_page_type: CorporateInformationPageType::AboutUs)
    assert_not corporate_information_page_2.valid?

    assert corporate_information_page_2.errors.full_messages.include?("Another 'About' page was already published for this organisation")
  end

  test 'should be valid if it is a new draft of the same document' do
    organisation = create(:organisation)
    corporate_information_page_1 = build(:corporate_information_page,
                                         organisation: organisation,
                                         corporate_information_page_type: CorporateInformationPageType::AboutUs,
                                         state: 'published',
                                         major_change_published_at: Time.zone.now)
    corporate_information_page_1.save!

    corporate_information_page_2 = build(:corporate_information_page,
                                         organisation: organisation,
                                         corporate_information_page_type: CorporateInformationPageType::AboutUs,
                                         document_id: corporate_information_page_1.document_id,
                                         state: 'draft')
    assert corporate_information_page_2.valid?
  end

  test 'should return search index data suitable for Rummageable' do
    organisation = create(:organisation)
    corporate_information_page = create(:corporate_information_page,
                                        corporate_information_page_type: CorporateInformationPageType::TermsOfReference,
                                        organisation: organisation)

    assert_equal corporate_information_page.content_id, corporate_information_page.search_index['content_id']
    assert_equal "#{organisation.name} \u2013 #{corporate_information_page.title}", corporate_information_page.search_index['title']
    assert_equal "/government/organisations/#{organisation.slug}/about/#{corporate_information_page.slug}", corporate_information_page.search_index['link']
  end

  test 'with_translations scope loads corporate information pages despite not have titles explicitly saved' do
    cip_1 = create(:corporate_information_page, title: nil)
    cip_2 = create(:corporate_information_page, title: 'Should not be saved')

    assert_equal [cip_1, cip_2], CorporateInformationPage.with_translations
  end

  test "should derive title from type" do
    corporate_information_page = build(:corporate_information_page, corporate_information_page_type: CorporateInformationPageType::TermsOfReference)
    assert_equal "Terms of reference", corporate_information_page.title
  end

  test "should translate title" do
    welsh_language_scheme_page = build(:corporate_information_page, corporate_information_page_type: CorporateInformationPageType::WelshLanguageScheme)
    assert_equal "Welsh language scheme", welsh_language_scheme_page.title
    I18n.with_locale(:cy) do
      assert_equal "Cynllun iaith Gymraeg", welsh_language_scheme_page.title
    end
  end

  test "should derive title from type and interpolate organisation acronym" do
    organisation = build(:organisation, acronym: "DCLG")
    corporate_information_page = build(:corporate_information_page, organisation: organisation, corporate_information_page_type: CorporateInformationPageType::Recruitment)
    assert_equal "Working for DCLG", corporate_information_page.title
  end

  test "should derive title from type and interpolate organisation name if no acronym" do
    organisation = build(:organisation, acronym: nil, name: "Department for Communities and Local Government")
    corporate_information_page = build(:corporate_information_page, organisation: organisation, corporate_information_page_type: CorporateInformationPageType::Recruitment)
    assert_equal "Working for Department for Communities and Local Government", corporate_information_page.title
  end

  test "should derive slug from type" do
    corporate_information_page = build(:corporate_information_page, corporate_information_page_type: CorporateInformationPageType::TermsOfReference)
    assert_equal "terms-of-reference", corporate_information_page.slug
  end

  test "can find type by slug" do
    assert_equal CorporateInformationPageType::TermsOfReference, CorporateInformationPageType.find('terms-of-reference')
  end

  test "when finding type by slug, raises if not found" do
    assert_raise ActiveRecord::RecordNotFound do
      CorporateInformationPageType.find('does-not-exist')
    end
  end

  test "#alternative_format_contact_email delegates to organisation" do
    email = stub("email")
    organisation = build(:organisation)
    organisation.expects(:alternative_format_contact_email).returns(email)
    corporate_information_page = build(:corporate_information_page, organisation: organisation)

    assert_equal email, corporate_information_page.alternative_format_contact_email
  end

  test "should support attachments" do
    organisation = build(:organisation_with_alternative_format_contact_email)
    corporate_information_page = build(:corporate_information_page, organisation: organisation)
    corporate_information_page.attachments << build(:file_attachment)
  end

  test "should be able to get corporate information pages for a particular menu" do
    organisation = create(:organisation_with_alternative_format_contact_email)

    by_menu_heading = {
      our_information: [
        CorporateInformationPageType::Statistics,
        CorporateInformationPageType::OurEnergyUse,
        CorporateInformationPageType::ComplaintsProcedure,
        CorporateInformationPageType::TermsOfReference,
        CorporateInformationPageType::OurGovernance,
        CorporateInformationPageType::Membership,
        CorporateInformationPageType::OfficeAccessAndOpeningTimes,
        CorporateInformationPageType::MediaEnquiries,
        CorporateInformationPageType::AccessibleDocumentsPolicy,
      ],
      jobs_and_contracts: [
        CorporateInformationPageType::Procurement,
        CorporateInformationPageType::Recruitment
      ],
      other: [
        CorporateInformationPageType::PublicationScheme,
        CorporateInformationPageType::WelshLanguageScheme,
        CorporateInformationPageType::PersonalInformationCharter,
        CorporateInformationPageType::SocialMediaUse,
        CorporateInformationPageType::AboutOurServices
      ]
    }

    by_menu_heading.values.flatten.each do |type|
      create(:corporate_information_page, organisation: organisation, corporate_information_page_type: type)
    end

    by_menu_heading.each_key do |menu_heading|
      assert_same_elements by_menu_heading[menu_heading], organisation.corporate_information_pages.by_menu_heading(menu_heading).map(&:corporate_information_page_type)
    end
  end

  test 'will not be indexed if the org it belongs to is not live on gov.uk' do
    joining_org = create(:organisation, govuk_status: 'joining')
    exempt_org = create(:organisation, govuk_status: 'exempt')
    transitioning_org = create(:organisation, govuk_status: 'transitioning')
    live_org = create(:organisation, govuk_status: 'live')

    corporate_information_page_1 = create(:corporate_information_page, :published, organisation: joining_org)
    corporate_information_page_2 = create(:corporate_information_page, :published, organisation: exempt_org)
    corporate_information_page_3 = create(:corporate_information_page, :published, organisation: transitioning_org)
    corporate_information_page_4 = create(:corporate_information_page, :published, organisation: live_org)

    Whitehall::SearchIndex.expects(:add).with(corporate_information_page_1).never
    Whitehall::SearchIndex.expects(:add).with(corporate_information_page_2).never
    Whitehall::SearchIndex.expects(:add).with(corporate_information_page_3).never
    Whitehall::SearchIndex.expects(:add).with(corporate_information_page_4).once
    corporate_information_page_1.update_in_search_index
    corporate_information_page_2.update_in_search_index
    corporate_information_page_3.update_in_search_index
    corporate_information_page_4.update_in_search_index
  end

  test 'until we launch worldwide will not be indexed if the org it belongs to is a worldwide org' do
    world_org = create(:worldwide_organisation)

    corp_page = create(:corporate_information_page, organisation: nil, worldwide_organisation: world_org)
    Whitehall::SearchIndex.expects(:add).with(corp_page).never
    corp_page.update_in_search_index
  end

  test "re-indexes the organisation after the 'About Us' CIP is saved" do
    org = create(:organisation, govuk_status: 'live')
    corp_page = create(
      :corporate_information_page,
      :published,
      organisation: org,
      corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id,
    )

    Whitehall::SearchIndex.expects(:add).with(org).once
    corp_page.save!
  end

  test "re-indexes the worldwide organisation after the 'About Us' CIP is saved" do
    worldwide_org = create(:worldwide_organisation)
    about_us = create(
      :corporate_information_page,
      :published,
      organisation: nil,
      worldwide_organisation: worldwide_org,
      corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id,
    )

    Whitehall::SearchIndex.expects(:add).with(worldwide_org).once
    about_us.save!
  end

  test "does not re-index organisation for other types of corporate info page" do
    org = create(:organisation, govuk_status: 'live')
    other_page = create(:corporate_information_page, :published, organisation: org)
    Whitehall::SearchIndex.expects(:add).with(org).never
    other_page.save!
  end

  test "does not re-index worldwide organisation for other types of corporate info page" do
    worldwide_org = create(:worldwide_organisation)
    other_page = create(
      :corporate_information_page,
      :published,
      organisation: nil,
      worldwide_organisation: worldwide_org,
    )
    Whitehall::SearchIndex.expects(:add).with(worldwide_org).never
    other_page.save!
  end
end
