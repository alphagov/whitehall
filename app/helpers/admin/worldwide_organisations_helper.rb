module Admin::WorldwideOrganisationsHelper
  def worldwide_organisation_tabs(worldwide_organisation)
    {
      "Details" => admin_worldwide_organisation_path(worldwide_organisation),
      "Translations" => admin_worldwide_organisation_translations_path(worldwide_organisation),
      "Offices" => admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation),
      "Access and opening times" => access_info_admin_worldwide_organisation_path(worldwide_organisation),
      "Social media accounts" => admin_worldwide_organisation_social_media_accounts_path(worldwide_organisation),
      "Corporate information pages" => admin_worldwide_organisation_corporate_information_pages_path(worldwide_organisation)
    }
  end

  def worldwide_office_shown_on_home_page_text(worldwide_organisation, worldwide_office)
    if worldwide_organisation.is_main_office?(worldwide_office)
      "Yes (as main office)"
    elsif worldwide_organisation.office_shown_on_home_page?(worldwide_office)
      "Yes"
    else
      "No"
    end
  end
end
