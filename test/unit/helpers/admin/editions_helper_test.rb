require "test_helper"

class Admin::EditionsHelperTest < ActionView::TestCase
  include Rails.application.routes.url_helpers
  include Admin::EditionRoutesHelper

  def govspeak_embedded_contacts(*_args)
    []
  end

  test "warn_about_lack_of_contacts_in_body? says no if the edition is not a news article" do
    (Edition.descendants - [NewsArticle] - NewsArticle.descendants).each do |not_a_news_article|
      assert_not warn_about_lack_of_contacts_in_body?(not_a_news_article.new)
    end
  end

  test "warn_about_lack_of_contacts_in_body? says no if the edition is a news article, but is not a press release" do
    (NewsArticleType.all - [NewsArticleType::PressRelease]).each do |not_a_press_release|
      assert_not warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: not_a_press_release))
    end
  end

  test "warn_about_lack_of_contacts_in_body? says no if the edition is a press release and it has at least one contact embedded in the body" do
    stubs(:govspeak_embedded_contacts).returns([build(:contact)])
    assert_not warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: NewsArticleType::PressRelease))
  end

  test "warn_about_lack_of_contacts_in_body? says yes if the edition is a press release and it has at no contacts embedded in the body" do
    stubs(:govspeak_embedded_contacts).returns([])
    assert warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: NewsArticleType::PressRelease))
  end

  test "default_edition_tabs includes document collection tab for a persisted document collection" do
    document_collection = build(:document_collection)
    assert_not_includes default_edition_tabs(document_collection).keys, "Collection documents"
    document_collection = create(:document_collection)
    assert_includes default_edition_tabs(document_collection).keys, "Collection documents"
  end

  test "#admin_author_filter_options excludes disabled users" do
    current_user, _another_user = *create_list(:user, 2)
    disabled_user = create(:disabled_user)

    assert_not_includes admin_author_filter_options(current_user), disabled_user
  end

  def one_hundred_thousand_words
    " There are ten words contained in this sentence there are" * 10_000
  end

  test "#show_link_check_report does not execute LinkCheckerApiService#has_links? when the edition is novel length" do
    edition = stub(body: one_hundred_thousand_words)
    LinkCheckerApiService.expects(:has_links?).never
    show_link_check_report?(edition)
  end

  test "#secondary_navigation_tabs_items for persisted consultations with no attachments" do
    consultation = build_stubbed(:consultation)

    expected_output = [
      {
        label: "Document",
        href: edit_admin_edition_path(consultation),
        current: false,
      },
      {
        label: "Attachments",
        href: admin_edition_attachments_path(consultation),
        current: false,
      },
      {
        label: "Public feedback",
        href: admin_consultation_public_feedback_path(consultation),
        current: true,
      },
      {
        label: "Final outcome",
        href: admin_consultation_outcome_path(consultation),
        current: false,
      },
    ]

    assert_equal expected_output, secondary_navigation_tabs_items(consultation, admin_consultation_public_feedback_path(consultation))
  end

  test "#secondary_navigation_tabs_items for persisted consultations with attachments" do
    consultation = build_stubbed(:consultation)
    consultation.stubs(:attachments).returns([build_stubbed(:file_attachment), build_stubbed(:file_attachment)])

    expected_output = [
      {
        label: "Document",
        href: edit_admin_edition_path(consultation),
        current: false,
      },
      {
        label: "Attachments<span class=\"govuk-tag govuk-tag--grey\">2</span>",
        href: admin_edition_attachments_path(consultation),
        current: false,
      },
      {
        label: "Public feedback",
        href: admin_consultation_public_feedback_path(consultation),
        current: false,
      },
      {
        label: "Final outcome",
        href: admin_consultation_outcome_path(consultation),
        current: true,
      },
    ]

    assert_equal expected_output, secondary_navigation_tabs_items(consultation, admin_consultation_outcome_path(consultation))
  end

  test "#secondary_navigation_tabs_items for persisted document collections" do
    document_collection = build_stubbed(:document_collection)

    expected_output = [
      {
        label: "Document",
        href: edit_admin_edition_path(document_collection),
        current: false,
      },
      {
        label: "Collection documents",
        href: admin_document_collection_groups_path(document_collection),
        current: true,
      },
    ]

    assert_equal expected_output, secondary_navigation_tabs_items(document_collection, admin_document_collection_groups_path(document_collection))
  end

  test "#secondary_navigation_tabs_items for persisted editions which do not allow attachments" do
    %i[case_study fatality_notice speech].each do |type|
      edition = build_stubbed(type)

      expected_output = [
        {
          label: "Document",
          href: edit_admin_edition_path(edition),
          current: true,
        },
      ]

      assert_equal expected_output, secondary_navigation_tabs_items(edition, edit_admin_edition_path(edition))
    end
  end

  test "#secondary_navigation_tabs_items for other persisted edition types with no attachments" do
    %i[corporate_information_page detailed_guide news_article publication].each do |type|
      if type == :corporate_information_page
        organisation = build_stubbed(:organisation)
        edition = build_stubbed(type, organisation:)
      else
        edition = build_stubbed(type)
      end

      expected_output = [
        {
          label: "Document",
          href: tab_url_for_edition(edition),
          current: true,
        },
        {
          label: "Attachments",
          href: admin_edition_attachments_path(edition),
          current: false,
        },
      ]

      assert_equal expected_output, secondary_navigation_tabs_items(edition, tab_url_for_edition(edition))
    end
  end

  test "#secondary_navigation_tabs_items for other persisted edition types with attachments" do
    %i[corporate_information_page detailed_guide news_article publication].each do |type|
      if type == :corporate_information_page
        organisation = build_stubbed(:organisation)
        edition = build_stubbed(type, organisation:)
      else
        edition = build_stubbed(type)
      end

      edition.stubs(:attachments).returns([build_stubbed(:file_attachment), build_stubbed(:file_attachment)])

      expected_output = [
        {
          label: "Document",
          href: tab_url_for_edition(edition),
          current: true,
        },
        {
          label: "Attachments<span class=\"govuk-tag govuk-tag--grey\">2</span>",
          href: admin_edition_attachments_path(edition),
          current: false,
        },
      ]

      assert_equal expected_output, secondary_navigation_tabs_items(edition, tab_url_for_edition(edition))
    end
  end

  test "#secondary_navigation_tabs_items for non-persisted editions" do
    %i[case_study consultation corporate_information_page detailed_guide document_collection fatality_notice news_article publication speech].each do |type|
      if type == :corporate_information_page
        organisation = build_stubbed(:organisation)
        edition = build(type, organisation:)
      else
        edition = build(type)
      end

      expected_output = [
        {
          label: "Document",
          href: tab_url_for_edition(edition),
          current: true,
        },
      ]

      assert_equal expected_output, secondary_navigation_tabs_items(edition, tab_url_for_edition(edition))
    end
  end
end
