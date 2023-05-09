require "test_helper"

class Admin::LegacyTabbedNavHelperTest < ActionView::TestCase
  tests Admin::TabbedNavHelper
  include Rails.application.routes.url_helpers
  include Admin::EditionRoutesHelper

  def preview_design_system?(_next_release)
    false
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
        label: "Attachments ",
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
        label: "Attachments <span class=\"govuk-tag govuk-tag--grey\">2</span>",
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
          label: "Attachments ",
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
          label: "Attachments <span class=\"govuk-tag govuk-tag--grey\">2</span>",
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

  test "#secondary_navigation_tabs_items for policy groups with no attachments" do
    policy_group = build_stubbed(:policy_group)

    expected_output = [
      {
        label: "Group",
        href: edit_admin_policy_group_path(policy_group),
        current: true,
      },
      {
        label: "Attachments ",
        href: admin_policy_group_attachments_path(policy_group),
        current: false,
      },
    ]

    assert_equal expected_output, secondary_navigation_tabs_items(policy_group, edit_admin_policy_group_path(policy_group))
  end

  test "#secondary_navigation_tabs_items for policy groups with attachments" do
    policy_group = build_stubbed(:policy_group)
    policy_group.stubs(:attachments).returns([build_stubbed(:file_attachment), build_stubbed(:file_attachment)])

    expected_output = [
      {
        label: "Group",
        href: edit_admin_policy_group_path(policy_group),
        current: false,
      },
      {
        label: "Attachments <span class=\"govuk-tag govuk-tag--grey\">2</span>",
        href: admin_policy_group_attachments_path(policy_group),
        current: true,
      },
    ]

    assert_equal expected_output, secondary_navigation_tabs_items(policy_group, admin_policy_group_attachments_path(policy_group))
  end

  test "#secondary_navigation_tabs_items for people" do
    person = build_stubbed(:person)

    expected_output = [
      {
        label: "Details",
        href: admin_person_path(person),
        current: false,
      },
      {
        label: "Translations",
        href: admin_person_translations_path(person),
        current: false,
      },
      {
        label: "Historical accounts",
        href: admin_person_historical_accounts_path(person),
        current: true,
      },
    ]

    assert_equal expected_output, secondary_navigation_tabs_items(person, admin_person_historical_accounts_path(person))
  end
end
