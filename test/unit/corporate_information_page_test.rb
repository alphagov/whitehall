require "test_helper"

class CorporateInformationPageTest < ActiveSupport::TestCase

  def self.should_be_invalid_without(type, attribute_name)
    test "#{type} should be invalid without #{attribute_name}" do
      document = build(type, attribute_name => nil)
      refute document.valid?
    end
  end

  should_be_invalid_without(:corporate_information_page, :type)
  should_be_invalid_without(:corporate_information_page, :body)
  should_be_invalid_without(:corporate_information_page, :organisation)

  test 'should return search index data suitable for Rummageable' do
    organisation = create(:organisation)
    corporate_information_page = create(:corporate_information_page,
      type: CorporateInformationPageType::TermsOfReference,
      organisation: organisation)

    assert_equal "#{organisation.name} - #{corporate_information_page.title}", corporate_information_page.search_index['title']
    assert_equal "/government/organisations/#{organisation.slug}/about/#{corporate_information_page.slug}", corporate_information_page.search_index['link']
  end

  test "should be invalid if same type already exists for this organisation" do
    organisation = create(:organisation)
    first = create(:corporate_information_page,
      type: CorporateInformationPageType::TermsOfReference,
      organisation: organisation)
    second = build(:corporate_information_page,
      type: CorporateInformationPageType::TermsOfReference,
      organisation: organisation)
    refute second.valid?
  end

  test "should be valid if same type already exists for another organisation" do
    first = create(:corporate_information_page,
      type: CorporateInformationPageType::TermsOfReference,
      organisation: create(:organisation))
    second = build(:corporate_information_page,
      type: CorporateInformationPageType::TermsOfReference,
      organisation: create(:organisation))
    assert second.valid?
  end

  test "should derive title from type" do
    corporate_information_page = build(:corporate_information_page, type: CorporateInformationPageType::TermsOfReference)
    assert_equal "Terms of reference", corporate_information_page.title
  end

  test "should derive title from type and interpolate orgnisation acronym" do
    organisation = build(:organisation, acronym: "DCLG")
    corporate_information_page = build(:corporate_information_page, organisation: organisation, type: CorporateInformationPageType::Recruitment)
    assert_equal "Working for DCLG", corporate_information_page.title
  end

  test "should derive title from type and interpolate orgnisation name if no acronym" do
    organisation = build(:organisation, acronym: nil, name: "Department for Communities and Local Government")
    corporate_information_page = build(:corporate_information_page, organisation: organisation, type: CorporateInformationPageType::Recruitment)
    assert_equal "Working for Department for Communities and Local Government", corporate_information_page.title
  end

  test "should derive slug from type" do
    corporate_information_page = build(:corporate_information_page, type: CorporateInformationPageType::TermsOfReference)
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
        CorporateInformationPageType::MediaEnquiries
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
      corporate_information_page = create(:corporate_information_page, organisation: organisation, type: type)
    end

    by_menu_heading.keys.each do |menu_heading|
      assert_same_elements by_menu_heading[menu_heading], organisation.corporate_information_pages.by_menu_heading(menu_heading).map(&:type)
    end
  end

  test 'will not be indexed if the org it belongs to is not live on gov.uk' do
    joining_org = create(:organisation, govuk_status: 'joining')
    exempt_org = create(:organisation, govuk_status: 'exempt')
    transitioning_org = create(:organisation, govuk_status: 'transitioning')
    live_org = create(:organisation, govuk_status: 'live')


    c1 = build(:corporate_information_page, organisation: joining_org)
    c2 = build(:corporate_information_page, organisation: exempt_org)
    c3 = build(:corporate_information_page, organisation: transitioning_org)
    c4 = build(:corporate_information_page, organisation: live_org)
    Whitehall::SearchIndex.expects(:add).with(c1).never
    c1.save

    Whitehall::SearchIndex.expects(:add).with(c2).never
    c2.save

    Whitehall::SearchIndex.expects(:add).with(c3).never
    c3.save

    Whitehall::SearchIndex.expects(:add).with(c4).once
    c4.save
  end

  test 'until we launch worldwide will not be indexed if the org it belongs to is a worldwide org' do
    world_org = create(:worldwide_organisation)

    corp_page = build(:corporate_information_page, organisation: world_org)
    Whitehall::SearchIndex.expects(:add).with(corp_page).never
    corp_page.save
  end
end
