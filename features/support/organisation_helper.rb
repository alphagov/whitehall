module OrganisationHelper
  def find_or_create_organisation(name)
    Organisation.find_by(name: name) || create(:organisation, name: name)
  end

  def create_org_and_stub_content_store(*args)
    organisation = create(*args)
    stub_organisation_in_content_store(
      args[1][:name],
      organisation.base_path,
      args[1][:translated_into]
    )
    organisation
  end

  def stub_organisation_in_content_store(name, base_path, locale = nil)
    content_item = {
      format: "organisation",
      title: name,
    }

    translated_path = locale ? "#{base_path}.#{locale}" : base_path
    content_store_has_item(translated_path, content_item)
  end

  def stub_organisation_homepage_in_content_store
    content_item = {
      format: "finder",
      title: "Organisation homepage",
    }
    content_store_has_item("/government/organisations", content_item)
  end

  def fill_in_organisation_translation_form(translation)
    translation = translation.stringify_keys

    fill_in "Name", with: translation["name"]
    fill_in "Acronym", with: translation["acronym"]
    fill_in "Logo formatted name", with: translation["logo formatted name"]
    click_on "Save"
  end

  def feature_policies_on_organisation(policies)
    policies.each do |policy|
      click_button "Feature #{policy}"
    end
  end

  def unfeature_organisation_policy(policy)
    click_link "Unfeature #{policy}"
  end

  def check_no_featured_policies
    refute page.has_css?("#policies")
  end

  def check_policies_are_featured_in_order(table)
    rows = find('ol.policies').all('li a')
    found_policies = rows.map { |row| [row.text.strip] }
    table.diff!(found_policies)
  end
end

World(OrganisationHelper)
