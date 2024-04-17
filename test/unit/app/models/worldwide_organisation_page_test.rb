require "test_helper"

class WorldwideOrganisationPageTest < ActiveSupport::TestCase
  test "creating a new page republishes the associated worldwide organisation" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    Whitehall::PublishingApi.expects(:save_draft).with(worldwide_organisation).once
    create(:worldwide_organisation_page, edition: worldwide_organisation)
  end

  test "updating an existing page republishes the associated worldwide organisation" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    page = create(:worldwide_organisation_page, edition: worldwide_organisation)
    page.body = "updated"
    Whitehall::PublishingApi.expects(:save_draft).with(worldwide_organisation).once
    page.save!
  end

  test "deleting a page republishes the associated worldwide organisation" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    page = create(:worldwide_organisation_page, edition: worldwide_organisation)
    Whitehall::PublishingApi.expects(:save_draft).with(worldwide_organisation).once
    page.destroy!
  end

  test "deleting a page discards the draft page" do
    worldwide_organisation = create(:editionable_worldwide_organisation)
    page = create(:worldwide_organisation_page, edition: worldwide_organisation)
    PublishingApiDiscardDraftWorker.expects(:perform_async).with(page.content_id, "en").once
    page.destroy!
  end

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

  test "should not be valid when a worldwide organisation page of that type already exists for the worldwide organisation" do
    organisation = create(:editionable_worldwide_organisation)
    create(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::TermsOfReference, edition: organisation)

    page = build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::TermsOfReference, edition: organisation.reload)

    assert_not page.valid?
    assert page.errors[:base].include?("Another 'Terms of reference' page already exists for this worldwide organisation")
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
