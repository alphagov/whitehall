module OrganisationHelper
  def find_or_create_organisation(name)
    Organisation.find_by(name: name) || create(:organisation, name: name)
  end

  def fill_in_organisation_translation_form(translation)
    translation = translation.stringify_keys

    fill_in "Name", with: translation["name"]
    fill_in "Acronym", with: translation["acronym"]
    fill_in "Logo formatted name", with: translation["logo formatted name"]
    click_on "Save"
  end
end

World(OrganisationHelper)
