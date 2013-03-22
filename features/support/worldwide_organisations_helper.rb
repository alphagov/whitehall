module WorldwideOrganisationsHelper
  def add_translation_to_worldwide_organisation(worldwide_organisation, translation)
    translation = translation.stringify_keys
    visit admin_worldwide_organisations_path
    within record_css_selector(worldwide_organisation) do
      click_link "Manage translations"
    end

    select translation["locale"], from: "Locale"
    click_on "Create translation"
    fill_in "Name", with: translation["name"]
    fill_in "Summary", with: translation["summary"]
    fill_in "Description", with: translation["description"]
    fill_in "Services", with: translation["services"]
    click_on "Save"
  end

  def edit_translation_for_worldwide_organisation(locale, name, translation)
    location = WorldwideOrganisation.find_by_name!(name)
    visit admin_worldwide_organisations_path
    within record_css_selector(location) do
      click_link "Manage translations"
    end
    click_link locale
    fill_in "Name", with: translation["name"]
    fill_in "Summary", with: translation["summary"]
    fill_in "Description", with: translation["description"]
    fill_in "Services", with: translation["services"]
    click_on "Save"
  end
end

World(WorldwideOrganisationsHelper)
