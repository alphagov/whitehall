module WorldwideOrganisationsHelper
  def add_translation_to_worldwide_organisation(worldwide_organisation, translation)
    translation = translation.stringify_keys
    visit admin_worldwide_organisations_path
    click_link "View #{worldwide_organisation.name}"
    click_link "Translations"

    select translation["locale"], from: "Locale"

    click_on "Next"
    fill_in "Name", with: translation["name"]
    click_on "Save"
  end

  def edit_translation_for_worldwide_organisation(locale, worldwide_organisation_name, translation)
    worldwide_organisation = WorldwideOrganisation.find_by!(name: worldwide_organisation_name)
    visit admin_worldwide_organisations_path
    unless using_design_system?
      within record_css_selector(worldwide_organisation) do
        click_link locale
      end

      fill_in "Name", with: translation["name"]
      click_on "Save"
    end
  end
end

World(WorldwideOrganisationsHelper)
