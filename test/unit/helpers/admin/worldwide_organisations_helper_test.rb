require "test_helper"

class Admin::WorldwideOrganisationsHelperTest < ActionView::TestCase
  test "#worldwide_organisation_tabs returns relevant tabs" do
    worldwide_organisation = build_stubbed(:worldwide_organisation)

    expected_output = [
      "Details",
      "Attachments",
      "Translations",
      "Offices",
      "Access and opening times",
      "Social media accounts",
      "Corporate information pages",
    ]

    assert_equal expected_output, worldwide_organisation_tabs(worldwide_organisation).keys
  end

  test "#worldwide_organisation_tabs includes Attachments tab with badge when worldwide organisation has attachments" do
    worldwide_organisation = build_stubbed(:worldwide_organisation)
    worldwide_organisation.stubs(:attachments).returns(stub("attachments", count: 1))

    assert_includes worldwide_organisation_tabs(worldwide_organisation).keys, "Attachments <span class='badge'>1</span>"
  end

  test "#worldwide_organisation_nav_items returns an array of hashes with the correct items" do
    worldwide_organisation = build_stubbed(:worldwide_organisation)
    current_path = admin_worldwide_organisation_path(worldwide_organisation)

    expected_output = [
      { label: "Details", href: admin_worldwide_organisation_path(worldwide_organisation), current: true },
      { label: "Attachments ", href: admin_worldwide_organisation_attachments_path(worldwide_organisation), current: false },
      { label: "Translations", href: admin_worldwide_organisation_translations_path(worldwide_organisation), current: false },
      { label: "Offices", href: admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation), current: false },
      { label: "Access and opening times", href: access_info_admin_worldwide_organisation_path(worldwide_organisation), current: false },
      { label: "Social media accounts", href: admin_worldwide_organisation_social_media_accounts_path(worldwide_organisation), current: false },
      { label: "Pages", href: admin_worldwide_organisation_corporate_information_pages_path(worldwide_organisation), current: false },
    ]

    assert_equal expected_output, worldwide_organisation_nav_items(worldwide_organisation, current_path)
  end

  test "#worldwide_organisation_nav_items includes Attachments nav item with badge when worldwide organisation has attachments" do
    worldwide_organisation = build_stubbed(:worldwide_organisation)
    worldwide_organisation.stubs(:attachments).returns(stub("attachments", count: 1))
    current_path = admin_worldwide_organisation_path(worldwide_organisation)

    labels = worldwide_organisation_nav_items(worldwide_organisation, current_path).map { |ni| ni[:label] }

    assert_includes labels, %(Attachments <span class="govuk-tag govuk-tag--grey">1</span>)
  end
end
