When(/^I create a worldwide organisation "([^"]*)" sponsored by the "([^"]*)"$/) do |name, sponsoring_organisation|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  select sponsoring_organisation, from: "Sponsoring organisations"
  click_on "Save"
end

When(/^I create a new worldwide organisation "([^"]*)" in "([^"]*)"$/) do |name, location|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  select location, from: "World location"
  click_on "Save"
end

When(/^I create a new worldwide organisation "([^"]*)" in  "([^"]*)" sponsored by the "([^"]*)"$/) do |name, location, sponsoring_organisation|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  select location, from: "World location"
  select sponsoring_organisation, from: "Sponsoring organisations"
  click_on "Save"
end

Then(/^I should see the(?: updated)? worldwide organisation information on the public website$/) do
  worldwide_organisation = WorldwideOrganisation.last
  visit worldwide_organisation_path(worldwide_organisation)
  expect(page).to have_title(worldwide_organisation.name)
end

Then(/^the "([^"]*)" logo should show correctly with the HMG crest$/) do |name|
  worldwide_organisation = WorldwideOrganisation.find_by(name:)
  expect(page).to have_selector(".gem-c-organisation-logo", text: worldwide_organisation.logo_formatted_name)
end

Then(/^I should see that it is part of the "([^"]*)"$/) do |sponsoring_organisation|
  expect(page).to have_selector(".sponsoring-organisation", text: sponsoring_organisation)
end

Then(/^I should see the worldwide organisation listed on the page$/) do
  worldwide_organisation = WorldwideOrganisation.last
  within ".meta" do
    expect(page).to have_content(worldwide_organisation.name)
  end
end

Then(/^I should see the worldwide location name "([^"]*)" on the worldwide organisation page$/) do |location_name|
  location = WorldLocation.find_by(name: location_name)
  worldwide_organisation = WorldwideOrganisation.last
  within record_css_selector(worldwide_organisation) do
    expect(page).to have_content(location.name)
  end
end

Then(/^I should see the worldwide organisation "([^"]*)" on the "([^"]*)" world location page$/) do |worldwide_organisation_name, location_name|
  location = WorldLocation.find_by(name: location_name)
  worldwide_organisation = WorldwideOrganisation.find_by(name: worldwide_organisation_name)
  visit world_location_path(location)
  within record_css_selector(worldwide_organisation) do
    expect(page).to have_content(worldwide_organisation_name)
  end
end

When(/^I update the worldwide organisation to set the name to "([^"]*)"$/) do |new_title|
  visit edit_admin_worldwide_organisation_path(WorldwideOrganisation.last)
  fill_in "Name", with: new_title
  click_on "Save"
end

When(/^I delete the worldwide organisation$/) do
  @worldwide_organisation = WorldwideOrganisation.last
  visit edit_admin_worldwide_organisation_path(@worldwide_organisation)
  click_on "delete"
end

Then(/^the worldwide organisation should not be visible from the public website$/) do
  expect { visit worldwide_organisation_path(@worldwide_organisation) }
    .to raise_error(ActiveRecord::RecordNotFound)
end

Given(/^a worldwide organisation "([^"]*)"$/) do |name|
  worg = create(:worldwide_organisation, name:)
  worg.main_office = create(:worldwide_office, worldwide_organisation: worg, title: "Main office for #{name}")
end

Given(/^a worldwide organisation "([^"]*)" exists for the world location "([^"]*)" with translations into "([^"]*)"$/) do |name, _country_name, translation|
  country = create(:world_location, active: true, translated_into: [translation])
  create(:worldwide_organisation, name:, world_locations: [country])
end

When(/^I add an "([^"]*)" office for the home page with address, phone number, and some services$/) do |description|
  service1 = create(:worldwide_service, name: "Dance lessons")
  _service2 = create(:worldwide_service, name: "Courses in advanced sword fighting")
  service3 = create(:worldwide_service, name: "Beard grooming")

  visit admin_worldwide_organisation_worldwide_offices_path(WorldwideOrganisation.last)
  click_link "Add"
  fill_in_contact_details(title: description, feature_on_home_page: "yes")
  select WorldwideOfficeType.all.sample.name, from: "Office type"

  check service1.name
  check service3.name

  click_on "Save"
end

Then(/^the "([^"]*)" office details should be shown on the public website$/) do |description|
  worldwide_org = WorldwideOrganisation.last
  visit worldwide_organisation_path(worldwide_org)
  worldwide_office = worldwide_org.offices.joins(contact: :translations).where(contact_translations: { title: description }).first

  within record_css_selector(worldwide_office) do
    expect(page).to have_selector(".gem-c-heading", text: worldwide_office.contact.title)
    # new lines cause challenges in matching to the rendering
    address = worldwide_office.contact.street_address.gsub(/\s+/, " ")
    expect(page).to have_content(address, normalize_ws: true)

    expect(page).to have_selector("span[dir='ltr']", text: worldwide_office.contact.contact_numbers.first.number)
  end
end

Then(/^I should be able to remove all services from the "(.*?)" office$/) do |description|
  worldwide_office = WorldwideOffice.joins(contact: :translations).where(contact_translations: { title: description }).first
  visit edit_admin_worldwide_organisation_worldwide_office_path(worldwide_organisation_id: WorldwideOrganisation.last.id, id: worldwide_office.id)
  available_services = worldwide_office.services.each { |service| uncheck "worldwide_office_service_ids_#{service.id}" }
  click_on "Save"

  visit edit_admin_worldwide_organisation_worldwide_office_path(worldwide_organisation_id: WorldwideOrganisation.last.id, id: worldwide_office.id)
  available_services.each do |service|
    expect(page).to have_field("worldwide_office_service_ids_#{service.id}", checked: false)
  end
end

Given(/^that the world location "([^"]*)" exists$/) do |country_name|
  create(:world_location, name: country_name, active: true)
end

Given(/^the worldwide organisation "([^"]*)" exists$/) do |worldwide_organisation_name|
  create(:worldwide_organisation, name: worldwide_organisation_name, logo_formatted_name: worldwide_organisation_name)
end

Given(/^a worldwide organisation "([^"]*)" with offices "([^"]*)" and "([^"]*)"$/) do |worldwide_organisation_name, contact_1_title, contact_2_title|
  worldwide_organisation = create(:worldwide_organisation, name: worldwide_organisation_name)
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation:, contact: create(:contact, title: contact_1_title)))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation:, contact: create(:contact, title: contact_2_title)))
end

When(/^I choose "([^"]*)" to be the main office$/) do |contact_title|
  worldwide_office = WorldwideOffice.joins(contact: :translations).where(contact_translations: { title: contact_title }).first
  visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  click_link "Offices"
  within record_css_selector(worldwide_office) do
    click_button "Set as main office"
  end
end

Then(/^the "([^"]*)" should be shown as the main office on the public website$/) do |contact_title|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_office = WorldwideOffice.joins(contact: :translations).where(contact_translations: { title: contact_title }).first
  visit worldwide_organisation_path(worldwide_organisation)
  within record_css_selector(worldwide_office) do
    expect(page).to have_content(contact_title)
  end
end

Then(/^I should see his name on the worldwide organisation page$/) do
  visit worldwide_organisation_path(WorldwideOrganisation.last)
  person = Person.last

  within record_css_selector(person) do
    expect(page).to have_content(person.name)
  end
end

Then(/^I should not see his name on the worldwide organisation page$/) do
  visit worldwide_organisation_path(WorldwideOrganisation.last)
  person = Person.last

  within record_css_selector(person) do
    expect(page).to_not have_content(person.name)
  end
end

When(/^I add default access information to the worldwide organisation$/) do
  visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  click_link "Access and opening times"
  click_link "Add default access information"
  fill_in "Body", with: "Default body information"
  click_button "Save"
end

Then(/^I should see the default access information on the public "([^"]*)" office page$/) do |office_name|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_office = WorldwideOffice.joins(contact: :translations).where(contact_translations: { title: office_name }).first
  visit worldwide_organisation_path(worldwide_organisation)
  within record_css_selector(worldwide_office) do
    click_link "Access and opening times"
  end

  within ".body" do
    expect(page).to have_content("Default body information")
  end
end

Given(/^a worldwide organisation "([^"]*)" with default access information$/) do |name|
  worldwide_organisation = create(:worldwide_organisation, name:)
  create(:access_and_opening_times, accessible: worldwide_organisation, body: "Default body information")
end

When(/^I edit the default access information for the worldwide organisation$/) do
  worldwide_organisation = WorldwideOrganisation.last
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link "Access and opening times"
  click_on "Edit"
  fill_in "Body", with: "Edited body information"
  click_button "Save"
end

Given(/^the offices "([^"]*)" and "([^"]*)"$/) do |contact_1_title, contact_2_title|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation:, contact: create(:contact, title: contact_1_title)))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation:, contact: create(:contact, title: contact_2_title)))
end

When(/^I give "([^"]*)" custom access information$/) do |office_name|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_office = WorldwideOffice.joins(contact: :translations).where(contact_translations: { title: office_name }).first
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link "Offices"
  within record_css_selector(worldwide_office) do
    click_on "Customise"
  end

  fill_in "Body", with: "Custom body information"
  click_button "Save"
end

Then(/^I should see the custom access information on the public "([^"]*)" office page$/) do |office_name|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_office = WorldwideOffice.joins(contact: :translations).where(contact_translations: { title: office_name }).first
  visit worldwide_organisation_path(worldwide_organisation)
  within record_css_selector(worldwide_office) do
    click_link "Access and opening times"
  end

  within ".body" do
    expect(page).to have_content("Custom body information")
  end
end

Then(/^I should see the updated default access information$/) do
  expect(page).to have_selector(".govspeak p", text: "Edited body information")
end

When(/^I add a new translation to the worldwide organisation "([^"]*)" with:$/) do |name, table|
  worldwide_organisation = WorldwideOrganisation.find_by!(name:)
  add_translation_to_worldwide_organisation(worldwide_organisation, table.rows_hash)
end

Then(/^when viewing the worldwide organisation "([^"]*)" with the locale "([^"]*)" I should see:$/) do |name, locale, table|
  worldwide_organisation = WorldwideOrganisation.find_by!(name:)
  translation = table.rows_hash

  visit worldwide_organisation_path(worldwide_organisation, locale:)

  expect(page).to have_selector(".worldwide-org-summary", text: translation["summary"])
  expect(page).to have_selector(".worldwide-org-description", text: translation["description"])
  expect(page).to have_selector(".worldwide-org-content", text: translation["services"])
end

Given(/^a worldwide organisation "([^"]*)" exists with a translation for the locale "([^"]*)"$/) do |name, native_locale_name|
  locale_code = Locale.find_by_language_name(native_locale_name).code
  country = create(:world_location, active: true, world_location_type: "world_location")
  create(:worldwide_organisation, name:, world_locations: [country], translated_into: [locale_code])
end

When(/^I edit the "([^"]*)" translation for the worldwide organisation "([^"]*)" setting:$/) do |locale, name, table|
  edit_translation_for_worldwide_organisation(locale, name, table.rows_hash)
end

Then(/^I should be able to associate "([^"]*)" with the worldwide organisation "([^"]*)"$/) do |edition_title, world_org_title|
  begin_editing_document edition_title
  select world_org_title, from: "edition_worldwide_organisation_ids"
  click_on "Save"
end

Then(/^I should be able to associate "([^"]*)" with the topical event "([^"]*)"$/) do |edition_title, topical_event_title|
  begin_editing_document edition_title
  select topical_event_title, from: "edition_topical_event_ids"
  click_on "Save"
end
