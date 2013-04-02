module OrganisationHelper
  def find_or_create_organisation(name)
    Organisation.find_by_name(name) || create(:organisation, name: name)
  end

  def fill_in_organisation_translation_form(translation)
    translation = translation.stringify_keys

    fill_in "Name", with: translation["name"]
    fill_in "Acronym", with: translation["acronym"]
    fill_in "Logo formatted name", with: translation["logo formatted name"]
    fill_in "About us", with: translation["about us"]
    fill_in "Description", with: translation["description"]
    click_on "Save"
  end

  def last_executive_office
    Organisation.executive_offices.last
  end
end

World(OrganisationHelper)
