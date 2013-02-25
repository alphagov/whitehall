module Admin::WorldwideOrganisationsHelper

  def worldwide_organisation_tab_navigation(worldwide_organisation, &block)
    tabs = {
      "Details" => admin_worldwide_organisation_path(worldwide_organisation),
      "Offices" => offices_admin_worldwide_organisation_path(worldwide_organisation),
      "Social media accounts" => admin_worldwide_organisation_social_media_accounts_path(worldwide_organisation),
      "Corporate information pages" => admin_worldwide_organisation_corporate_information_pages_path(worldwide_organisation)
    }

    tab_navigation(tabs, &block)
  end
end
