require "test_helper"

class Admin::EditionsHelperTest < ActionView::TestCase
  def current_user
    @user
  end

  setup do
    @user = create(:user, name: "Test user")
  end

  test "#admin_author_filter_options excludes users whose accounts have been disabled" do
    current_user, _another_user = *create_list(:user, 2)
    disabled_user = create(:disabled_user)

    assert_not_includes admin_author_filter_options(current_user), disabled_user
  end

  test "#admin_author_filter_options returns other users in alphabetical order" do
    create(:user, name: "User A")
    create(:user, name: "User C")
    create(:user, name: "User B")
    options = admin_author_filter_options(@user)
    option_names = options.map(&:first)
    assert_equal ["All authors", "Me (Test user)", "User A", "User B", "User C"], option_names
  end

  def one_hundred_thousand_words
    " There are ten words contained in this sentence there are" * 10_000
  end

  test "#show_link_check_report does not execute LinkCheckerApiService#has_links? when the edition is novel length" do
    edition = stub(body: one_hundred_thousand_words)
    LinkCheckerApiService.expects(:has_links?).never
    show_link_check_report?(edition)
  end

  test "#reset_search_fields_query_string_params returns the correct params when the user has no organisation" do
    user = build_stubbed(:user)
    expected_result = "#{admin_editions_path}?state=active#anchor"

    assert_equal expected_result, reset_search_fields_query_string_params(user, admin_editions_path, "#anchor")
  end

  test "#reset_search_fields_query_string_params returns the correct params when the user belongs to an organisation and the filter action isn't the admin_editions_path" do
    organisation = build_stubbed(:organisation)
    user = build_stubbed(:user, organisation:)
    expected_result = "/any-other-path?state=active#anchor"

    assert_equal expected_result, reset_search_fields_query_string_params(user, "/any-other-path", "#anchor")
  end

  test "#reset_search_fields_query_string_params returns the correct params when the user belongs to an organisation and the filter action is the admin_editions_path" do
    organisation = build_stubbed(:organisation)
    user = build_stubbed(:user, organisation:)
    expected_result = "#{admin_editions_path}?state=active&organisation=#{organisation.id}#anchor"

    assert_equal expected_result, reset_search_fields_query_string_params(user, admin_editions_path, "#anchor")
  end

  test "#edition_type returns a concatenated string where a standard edition has a group" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type", { "settings" => { "configurable_document_group" => "test_group" } }))
    edition = build(:standard_edition)

    assert_equal "Test group: Test type", edition_type(edition)
  end

  test "#edition_type returns a single string where a standard edition does not have a group" do
    ConfigurableDocumentType.setup_test_types(build_configurable_document_type("test_type"))
    edition = build(:standard_edition)

    assert_equal "Test type", edition_type(edition)
  end

  test "#edition_type returns a concatenated string where an edition has a parent type" do
    publication = build(:publication, publication_type: PublicationType::IndependentReport)
    speech = build(:speech, speech_type: SpeechType::WrittenStatement)
    corporate_information_page = build(:publication_scheme_corporate_information_page)

    assert_equal "Publication: Independent report", edition_type(publication)
    assert_equal "Speech: Written statement to Parliament", edition_type(speech)
    assert_equal "Corporate information page: Publication scheme", edition_type(corporate_information_page)
  end

  test "#edition_type returns a single string or custom logic where an edition does not have a parent type" do
    call_for_evidence = build(:open_call_for_evidence)
    case_study = build(:case_study)
    consultation = build(:open_consultation)
    guide = build(:detailed_guide)
    collection = build(:document_collection)
    fatality_notice = build(:fatality_notice)
    statistical_data_set = build(:statistical_data_set)
    ww_org = build(:worldwide_organisation)

    assert_equal "Worldwide organisation", edition_type(ww_org)
    assert_equal "Detailed guide", edition_type(guide)
    assert_equal "Call for evidence: Open call for evidence", edition_type(call_for_evidence)
    assert_equal "Case study", edition_type(case_study)
    assert_equal "Consultation: Open consultation", edition_type(consultation)
    assert_equal "Document collection", edition_type(collection)
    assert_equal "Fatality notice", edition_type(fatality_notice)
    assert_equal "Statistical data set", edition_type(statistical_data_set)
  end

  test "#edition_title_link_or_edition_title returns a link to the edition with its title as the text when the edition has a public URL" do
    edition = build(:published_edition, title: "It's my title!")
    public_url = "https://gov.uk/my-public-url"
    edition.stubs(:public_url).returns(public_url)

    assert_equal '<a class="govuk-link" href="https://gov.uk/my-public-url">It\'s my title!</a>', edition_title_link_or_edition_title(edition)
  end

  test "#edition_title_link_or_edition_title returns the edition title when the edition has no public URL" do
    edition = build(:published_edition, title: "It's my title!")
    edition.stubs(:public_url).returns(nil)

    assert_equal "It's my title!", edition_title_link_or_edition_title(edition)
  end

  test "#status_text returns just the state if it is anything other than unpublished or withdrawn" do
    edition = build(:published_edition)

    assert_equal "Published", status_text(edition)
  end

  test "#status_text returns both the state and time information if it is withdrawn" do
    edition = create(:withdrawn_edition)

    assert_equal "Withdrawn (less than a minute ago)", status_text(edition)
  end

  test "#status_text has special handling for unpublished (due to consolidation)" do
    alternative_url = "https://gov.uk/foo"
    edition = create(:edition, :unpublished)

    edition.unpublishing.alternative_url = alternative_url
    edition.unpublishing.unpublishing_reason_id = UnpublishingReason::CONSOLIDATED_ID
    edition.unpublishing.save!
    assert_equal "Unpublished (less than a minute ago) due to being consolidated into another page. User is redirected from<br><a href='https://www.test.gov.uk#{edition.base_path}'>https://www.test.gov.uk#{edition.base_path}</a><br>to<br><a href='#{alternative_url}'>#{alternative_url}</a>", status_text(edition)
  end

  test "#status_text has special handling for unpublished (due to publish in error) - redirect to alternative URL" do
    alternative_url = "https://gov.uk/foo"
    edition = create(:edition, :unpublished)
    edition.unpublishing.alternative_url = alternative_url
    edition.unpublishing.unpublishing_reason_id = UnpublishingReason::PUBLISHED_IN_ERROR_ID
    edition.unpublishing.created_at = 1.year.ago
    edition.unpublishing.alternative_url = alternative_url
    edition.unpublishing.redirect = true
    edition.unpublishing.save!

    assert_equal "Unpublished (about 1 year ago) due to being published in error. User is redirected from<br><a href='https://www.test.gov.uk#{edition.base_path}'>https://www.test.gov.uk#{edition.base_path}</a><br>to<br><a href='#{alternative_url}'>#{alternative_url}</a>", status_text(edition)
  end

  test "#status_text has special handling for unpublished (due to publish in error) - no explanation or alternative URL (i.e. leads to a 410 Gone page)" do
    edition = create(:edition, :unpublished)
    edition.unpublishing.unpublishing_reason_id = UnpublishingReason::PUBLISHED_IN_ERROR_ID
    edition.unpublishing.alternative_url = ""
    edition.unpublishing.explanation = ""
    edition.unpublishing.redirect = false
    edition.unpublishing.save!

    assert_equal "Unpublished (less than a minute ago) due to being published in error.", status_text(edition)
  end

  test "#status_text has special handling for unpublished (due to publish in error) - explanation provided, no alternative URL" do
    edition = create(:edition, :unpublished)

    edition.unpublishing.unpublishing_reason_id = UnpublishingReason::PUBLISHED_IN_ERROR_ID
    edition.unpublishing.alternative_url = ""
    edition.unpublishing.redirect = false
    edition.unpublishing.explanation = "the doc was published in error"
    edition.unpublishing.save!

    assert_equal "Unpublished (less than a minute ago) due to being published in error. User-facing reason: 'the doc was published in error'.", status_text(edition)
  end

  test "#status_text has special handling for unpublished (due to publish in error) - no explanation, but an alternative URL" do
    alternative_url = "https://gov.uk/foo"
    edition = create(:edition, :unpublished)

    edition.unpublishing.unpublishing_reason_id = UnpublishingReason::PUBLISHED_IN_ERROR_ID
    edition.unpublishing.alternative_url = alternative_url
    edition.unpublishing.redirect = false
    edition.unpublishing.explanation = ""
    edition.unpublishing.save!

    assert_equal "Unpublished (less than a minute ago) due to being published in error. Alternative URL displayed to user:<br><a href='#{alternative_url}'>#{alternative_url}</a>", status_text(edition)
  end

  test "#status_text has special handling for unpublished (due to publish in error) - explanation and an alternative URL provided" do
    alternative_url = "https://gov.uk/foo"
    edition = create(:edition, :unpublished)

    edition.unpublishing.unpublishing_reason_id = UnpublishingReason::PUBLISHED_IN_ERROR_ID
    edition.unpublishing.alternative_url = alternative_url
    edition.unpublishing.explanation = "the doc was published in error"
    edition.unpublishing.redirect = false
    edition.unpublishing.save!

    expected_text = "Unpublished (less than a minute ago) due to being published in error. " \
                    "User-facing reason: 'the doc was published in error'. " \
                    "Alternative URL displayed to user:<br><a href='#{alternative_url}'>#{alternative_url}</a>"
    assert_equal(expected_text, status_text(edition))
  end
end
