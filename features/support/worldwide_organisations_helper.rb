module WorldwideOrganisationsHelper
  def add_translation_to_worldwide_organisation(worldwide_organisation, translation)
    translation = translation.stringify_keys
    visit admin_worldwide_organisations_path
    within record_css_selector(worldwide_organisation) do
      click_link worldwide_organisation.name
    end
    click_link "Translations"

    select translation["locale"], from: "Locale"
    click_on "Create translation"
    fill_in "Name", with: translation["name"]
    fill_in "Summary", with: translation["summary"]
    fill_in "Body", with: translation["body"]
    click_on "Save"
  end

  def edit_translation_for_worldwide_organisation(locale, worldwide_organisation_name, translation)
    worldwide_organisation = WorldwideOrganisation.find_by!(name: worldwide_organisation_name)
    visit admin_worldwide_organisations_path

    within record_css_selector(worldwide_organisation) do
      click_link locale
    end

    fill_in "Name", with: translation["name"]
    fill_in "Summary", with: translation["summary"]
    fill_in "Body", with: translation["body"]
    click_on "Save"
  end
end

World(WorldwideOrganisationsHelper)
