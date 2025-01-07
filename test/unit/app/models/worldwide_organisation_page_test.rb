require "test_helper"

class WorldwideOrganisationPageTest < ActiveSupport::TestCase
  test "creating a new page republishes the associated worldwide organisation" do
    worldwide_organisation = create(:worldwide_organisation)
    Whitehall::PublishingApi.expects(:save_draft).with(worldwide_organisation).once
    page = build(:worldwide_organisation_page, edition: worldwide_organisation)
    Whitehall::PublishingApi.expects(:save_draft).with(page, "major").once
    page.save!
  end

  test "updating an existing page republishes the associated worldwide organisation" do
    worldwide_organisation = create(:worldwide_organisation)
    page = create(:worldwide_organisation_page, edition: worldwide_organisation)
    page.body = "updated"
    Whitehall::PublishingApi.expects(:save_draft).with(worldwide_organisation).once
    Whitehall::PublishingApi.expects(:save_draft).with(page, "major").once
    page.save!
  end

  test "deleting a page republishes the associated worldwide organisation" do
    worldwide_organisation = create(:worldwide_organisation)
    page = create(:worldwide_organisation_page, edition: worldwide_organisation)
    Whitehall::PublishingApi.expects(:save_draft).with(worldwide_organisation).once
    page.destroy!
  end

  test "deleting a page discards the draft page" do
    worldwide_organisation = create(:worldwide_organisation)
    page = create(:worldwide_organisation_page, edition: worldwide_organisation)
    PublishingApiDiscardDraftWorker.expects(:perform_async).with(page.content_id, "en").once
    page.destroy!
  end

  %w[body corporate_information_page_type_id summary].each do |param|
    test "should not be valid without a #{param}" do
      assert_not build(:worldwide_organisation_page, param.to_sym => nil).valid?
    end
  end

  test "should not be valid without a worldwide organisation" do
    page = build(:worldwide_organisation_page, edition: nil)

    assert_not page.valid?
    assert page.errors[:edition].include?("cannot be blank")
  end

  test "should not be valid when corporate information page type is `about us`" do
    page = build(:worldwide_organisation_page, corporate_information_page_type: CorporateInformationPageType::AboutUs)

    assert_not page.valid?
    assert page.errors[:corporate_information_page_type_id].include?("Type cannot be `About us`")
  end

  test "should not be valid when a worldwide organisation page of that type already exists for the worldwide organisation" do
    organisation = create(:worldwide_organisation)
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
    worldwide_organisation = build(:worldwide_organisation, title: "British Antarctic Territory")
    page = build(:worldwide_organisation_page, edition: worldwide_organisation, corporate_information_page_type: CorporateInformationPageType::Recruitment)
    assert_equal "Working for British Antarctic Territory", page.title
  end

  test "#missing_translations should only include worldwide organisation translations" do
    worldwide_organisation = create(:worldwide_organisation, translated_into: %i[de es fr])
    page = create(:worldwide_organisation_page, edition: worldwide_organisation, translated_into: [:es])

    expected_locales = %i[de fr].map { |l| Locale.new(l) }
    assert_equal expected_locales, page.missing_translations
  end

  test "should be valid when translated into a language that the worldwide organisation has" do
    worldwide_organisation = create(:worldwide_organisation, translated_into: %i[de es fr])
    page = create(:worldwide_organisation_page, edition: worldwide_organisation, translated_into: %i[fr])

    assert page.valid?
  end

  test "should not be valid when translated into a language that the worldwide organisation does not have" do
    worldwide_organisation = create(:worldwide_organisation, translated_into: %i[de es fr])
    page = create(:worldwide_organisation_page, edition: worldwide_organisation, translated_into: %i[cy es-419])

    assert_not page.valid?
    assert page.errors[:base].include?("Translations 'cy, es-419' do not exist for this worldwide organisation")
  end
end
