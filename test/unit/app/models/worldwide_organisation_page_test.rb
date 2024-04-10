require "test_helper"

class WorldwideOrganisationPageTest < ActiveSupport::TestCase
  %w[body corporate_information_page_type_id].each do |param|
    test "should not be valid without a #{param}" do
      assert_not build(:worldwide_organisation_page, param.to_sym => nil).valid?
    end
  end

  test "should not be valid without a worldwide organisation" do
    page = build(:worldwide_organisation_page, edition: nil)

    assert_not page.valid?
    assert page.errors[:edition].include?("can't be blank")
  end

  test "should not be valid when corporate information page type is `about us`" do
    page = build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::AboutUs)

    assert_not page.valid?
    assert page.errors[:corporate_information_page_type_id].include?("Type cannot be `About us`")
  end

  test "should derive title from type" do
    page = build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::TermsOfReference)
    assert_equal "Terms of reference", page.title
  end

  test "should translate title" do
    welsh_language_scheme_page = build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::WelshLanguageScheme)
    assert_equal "Welsh language scheme", welsh_language_scheme_page.title
    I18n.with_locale(:cy) do
      assert_equal "Cynllun iaith Gymraeg", welsh_language_scheme_page.title
    end
  end

  test "should derive title from type and interpolate organisation name" do
    worldwide_organisation = build(:editionable_worldwide_organisation, title: "British Antarctic Territory")
    page = build(:worldwide_organisation_page, edition: worldwide_organisation, corporate_information_page_type: CorporateInformationPageType::Recruitment)
    assert_equal "Working for British Antarctic Territory", page.title
  end
end
