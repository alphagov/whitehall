module OrganisationTestHelper
  def find_or_create_organisation(name)
    Organisation.find_by(name:) || create(:organisation, name:)
  end

  def create_org_and_stub_content_store(*args)
    organisation = create(*args) # rubocop:disable Rails/SaveBang
    stub_organisation_in_content_store(
      args[1][:name],
      organisation.base_path,
      args[1][:translated_into],
    )
    organisation
  end

  def stub_organisation_in_content_store(name, base_path, locale = nil)
    content_item = {
      format: "organisation",
      title: name,
    }

    translated_path = locale ? "#{base_path}.#{locale}" : base_path
    stub_content_store_has_item(translated_path, content_item)
  end

  def stub_organisation_homepage_in_content_store
    content_item = {
      format: "finder",
      title: "Organisation homepage",
    }
    stub_content_store_has_item("/government/organisations", content_item)
  end

  def fill_in_organisation_translation_form(translation)
    translation = translation.stringify_keys

    fill_in "Name", with: translation["name"]
    fill_in "Acronym", with: translation["acronym"]
    fill_in "Logo formatted name", with: translation["logo formatted name"]
    click_on "Save"
  end
end

World(OrganisationTestHelper)
