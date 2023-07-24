require "test_helper"

class Admin::OrganisationHelperTest < ActionView::TestCase
  test "#topical_event_dates_string handles a topical event with a start date but no end date" do
    topical_event = create(:topical_event, start_date: Time.zone.today)

    assert_equal "11 November 2011", topical_event_dates_string(topical_event)
  end

  test "#topical_event_dates_string handles a topical event with start and end dates" do
    topical_event = create(:topical_event, start_date: Time.zone.today, end_date: Time.zone.today + 1.week)

    assert_equal "11 November 2011 to 18 November 2011", topical_event_dates_string(topical_event)
  end

  test "#topical_event_dates_string handles a topical event with no dates" do
    topical_event = create(:topical_event)

    assert_equal "", topical_event_dates_string(topical_event)
  end

  test "#organisation_nav_items when organisation doesn't have a translation" do
    organisation = build_stubbed(:organisation)
    current_path = admin_organisation_corporate_information_pages_path(organisation)

    expected_output = [
      { label: "Details", href: admin_organisation_path(organisation), current: false },
      { label: "About", href: about_admin_organisation_path(organisation), current: false },
      { label: "Contacts", href: admin_organisation_contacts_path(organisation), current: false },
      { label: "Features", href: features_admin_organisation_path(organisation, locale: I18n.default_locale), current: false },
      { label: "Pages", href: admin_organisation_corporate_information_pages_path(organisation), current: true },
      { label: "Social media accounts", href: admin_organisation_social_media_accounts_path(organisation), current: false },
      { label: "People", href: admin_organisation_people_path(organisation), current: false },
      { label: "Translations", href: admin_organisation_translations_path(organisation), current: false },
      { label: "Financial Reports", href: admin_organisation_financial_reports_path(organisation), current: false },
    ]

    assert_equal expected_output, organisation_nav_items(organisation, current_path)
  end

  test "#organisation_nav_items when organisation has translated features" do
    organisation = create(:organisation, :translated, translated_into: "fr")

    current_path = admin_organisation_path(organisation)

    expected_output = [
      { label: "Details", href: admin_organisation_path(organisation), current: true },
      { label: "About", href: about_admin_organisation_path(organisation), current: false },
      { label: "Contacts", href: admin_organisation_contacts_path(organisation), current: false },
      { label: "Features", href: features_admin_organisation_path(organisation, locale: I18n.default_locale), current: false },
      { label: "Features (Français)", href: features_admin_organisation_path(organisation, locale: "fr"), current: false },
      { label: "Pages", href: admin_organisation_corporate_information_pages_path(organisation), current: false },
      { label: "Social media accounts", href: admin_organisation_social_media_accounts_path(organisation), current: false },
      { label: "People", href: admin_organisation_people_path(organisation), current: false },
      { label: "Translations", href: admin_organisation_translations_path(organisation), current: false },
      { label: "Financial Reports", href: admin_organisation_financial_reports_path(organisation), current: false },
    ]

    assert_equal expected_output, organisation_nav_items(organisation, current_path)
  end

  test "#organisation_nav_items when organisation which is allowed to create promotional features" do
    organisation = build_stubbed(:executive_office)
    current_path = admin_organisation_financial_reports_path(organisation)

    expected_output = [
      { label: "Details", href: admin_organisation_path(organisation), current: false },
      { label: "About", href: about_admin_organisation_path(organisation), current: false },
      { label: "Contacts", href: admin_organisation_contacts_path(organisation), current: false },
      { label: "Promotional features", href: admin_organisation_promotional_features_path(organisation), current: false },
      { label: "Features", href: features_admin_organisation_path(organisation, locale: I18n.default_locale), current: false },
      { label: "Pages", href: admin_organisation_corporate_information_pages_path(organisation), current: false },
      { label: "Social media accounts", href: admin_organisation_social_media_accounts_path(organisation), current: false },
      { label: "People", href: admin_organisation_people_path(organisation), current: false },
      { label: "Translations", href: admin_organisation_translations_path(organisation), current: false },
      { label: "Financial Reports", href: admin_organisation_financial_reports_path(organisation), current: true },
    ]

    assert_equal expected_output, organisation_nav_items(organisation, current_path)
  end

  test "#organisation_index_rows returns an array of arrays with the user_organisation first followed by all orgs" do
    organisation1 = build_stubbed(:executive_office, name: "Org 1", govuk_status: "live")
    organisation2 = build_stubbed(:ministerial_department, :closed, name: "Org 2")
    user_organisation = build_stubbed(:devolved_administration, name: "Org 3", govuk_status: "exempt")

    expected_output = [
      [
        {
          text: tag.span(user_organisation.name, class: "govuk-!-font-weight-bold"),
        },
        {
          text: user_organisation.govuk_status,
        },
        {
          text: link_to(sanitize("View #{tag.span(user_organisation.name, class: 'govuk-visually-hidden')}"), admin_organisation_path(user_organisation), class: "govuk-link") +
            link_to(sanitize("Delete #{tag.span(user_organisation.name, class: 'govuk-visually-hidden')}"), confirm_destroy_admin_organisation_path(user_organisation), class: "govuk-link gem-link--destructive govuk-!-margin-left-3"),
        },
      ],
      [
        {
          text: tag.span(organisation1.name, class: "govuk-!-font-weight-bold"),
        },
        {
          text: organisation1.govuk_status,
        },
        {
          text: link_to(sanitize("View #{tag.span(organisation1.name, class: 'govuk-visually-hidden')}"), admin_organisation_path(organisation1), class: "govuk-link") +
            link_to(sanitize("Delete #{tag.span(organisation1.name, class: 'govuk-visually-hidden')}"), confirm_destroy_admin_organisation_path(organisation1), class: "govuk-link gem-link--destructive govuk-!-margin-left-3"),
        },
      ],
      [
        {
          text: tag.span(organisation2.name, class: "govuk-!-font-weight-bold"),
        },
        {
          text: organisation2.govuk_status,
        },
        {
          text: link_to(sanitize("View #{tag.span(organisation2.name, class: 'govuk-visually-hidden')}"), admin_organisation_path(organisation2), class: "govuk-link") +
            link_to(sanitize("Delete #{tag.span(organisation2.name, class: 'govuk-visually-hidden')}"), confirm_destroy_admin_organisation_path(organisation2), class: "govuk-link gem-link--destructive govuk-!-margin-left-3"),
        },
      ],
      [
        {
          text: tag.span(user_organisation.name, class: "govuk-!-font-weight-bold"),
        },
        {
          text: user_organisation.govuk_status,
        },
        {
          text: link_to(sanitize("View #{tag.span(user_organisation.name, class: 'govuk-visually-hidden')}"), admin_organisation_path(user_organisation), class: "govuk-link") +
            link_to(sanitize("Delete #{tag.span(user_organisation.name, class: 'govuk-visually-hidden')}"), confirm_destroy_admin_organisation_path(user_organisation), class: "govuk-link gem-link--destructive govuk-!-margin-left-3"),
        },
      ],
    ]

    assert_equal expected_output, organisation_index_rows(user_organisation, [organisation1, organisation2, user_organisation])
  end

  test "#organisation_index_rows returns an array of arrays for all orgs when no user_organisation is passed in" do
    organisation1 = build_stubbed(:executive_office, name: "Org 1", govuk_status: "live")
    organisation2 = build_stubbed(:ministerial_department, :closed, name: "Org 2")
    organisation3 = build_stubbed(:devolved_administration, name: "Org 3", govuk_status: "exempt")

    expected_output = [
      [
        {
          text: tag.span(organisation1.name, class: "govuk-!-font-weight-bold"),
        },
        {
          text: organisation1.govuk_status,
        },
        {
          text: link_to(sanitize("View #{tag.span(organisation1.name, class: 'govuk-visually-hidden')}"), admin_organisation_path(organisation1), class: "govuk-link") +
            link_to(sanitize("Delete #{tag.span(organisation1.name, class: 'govuk-visually-hidden')}"), confirm_destroy_admin_organisation_path(organisation1), class: "govuk-link gem-link--destructive govuk-!-margin-left-3"),
        },
      ],
      [
        {
          text: tag.span(organisation2.name, class: "govuk-!-font-weight-bold"),
        },
        {
          text: organisation2.govuk_status,
        },
        {
          text: link_to(sanitize("View #{tag.span(organisation2.name, class: 'govuk-visually-hidden')}"), admin_organisation_path(organisation2), class: "govuk-link") +
            link_to(sanitize("Delete #{tag.span(organisation2.name, class: 'govuk-visually-hidden')}"), confirm_destroy_admin_organisation_path(organisation2), class: "govuk-link gem-link--destructive govuk-!-margin-left-3"),
        },
      ],
      [
        {
          text: tag.span(organisation3.name, class: "govuk-!-font-weight-bold"),
        },
        {
          text: organisation3.govuk_status,
        },
        {
          text: link_to(sanitize("View #{tag.span(organisation3.name, class: 'govuk-visually-hidden')}"), admin_organisation_path(organisation3), class: "govuk-link") +
            link_to(sanitize("Delete #{tag.span(organisation3.name, class: 'govuk-visually-hidden')}"), confirm_destroy_admin_organisation_path(organisation3), class: "govuk-link gem-link--destructive govuk-!-margin-left-3"),
        },
      ],
    ]

    assert_equal expected_output, organisation_index_rows(nil, [organisation1, organisation2, organisation3])
  end
end
