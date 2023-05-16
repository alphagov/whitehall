require "test_helper"

class Admin::WorldwideOrganisationsHelperTest < ActionView::TestCase
  test "#worldwide_organisation_tabs returns relevant tabs" do
    worldwide_organisation = build_stubbed(:worldwide_organisation)

    expected_output = [
      "Details",
      "Translations",
      "Offices",
      "Access and opening times",
      "Social media accounts",
      "Corporate information pages",
    ]

    assert_equal expected_output, worldwide_organisation_tabs(worldwide_organisation).keys
  end

  test "#worldwide_organisation_nav_items returns an array of hashes with the correct items" do
    worldwide_organisation = build_stubbed(:worldwide_organisation)
    current_path = admin_worldwide_organisation_path(worldwide_organisation)

    expected_output = [
      { label: "Details", href: admin_worldwide_organisation_path(worldwide_organisation), current: true },
      { label: "Translations", href: admin_worldwide_organisation_translations_path(worldwide_organisation), current: false },
      { label: "Offices", href: admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation), current: false },
      { label: "Access and opening times", href: access_info_admin_worldwide_organisation_path(worldwide_organisation), current: false },
      { label: "Social media accounts", href: admin_worldwide_organisation_social_media_accounts_path(worldwide_organisation), current: false },
      { label: "Pages", href: admin_worldwide_organisation_corporate_information_pages_path(worldwide_organisation), current: false },
    ]

    assert_equal expected_output, worldwide_organisation_nav_items(worldwide_organisation, current_path)
  end
end
