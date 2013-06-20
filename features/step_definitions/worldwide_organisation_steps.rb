When /^I create a worldwide organisation "([^"]*)" sponsored by the "([^"]*)" with a summary, description and services$/ do |name, sponsoring_organisation|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  fill_in "Summary", with: "Worldwide organisation summary"
  fill_in "Description", with: "Worldwide **organisation** description"
  fill_in "Services", with: "## Passport renewals\n\nYou can renew your passport"
  select sponsoring_organisation, from: "Sponsoring organisations"
  click_on "Save"
end

When /^I create a new worldwide organisation "([^"]*)" in "([^"]*)"$/ do |name, location|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  fill_in "Summary", with: "Worldwide organisation summary"
  fill_in "Description", with: "Worldwide **organisation** description"
  select location, from: "World location"
  click_on "Save"
end

When /^I create a new worldwide organisation "([^"]*)" in  "([^"]*)" sponsored by the "([^"]*)"$/ do |name, location, sponsoring_organisation|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  fill_in "Summary", with: "Worldwide organisation summary"
  fill_in "Description", with: "Worldwide **organisation** description"
  select location, from: "World location"
  select sponsoring_organisation, from: "Sponsoring organisations"
  click_on "Save"
end


Then /^I should see the(?: updated)? worldwide organisation information on the public website$/ do
  worldwide_organisation = WorldwideOrganisation.last
  visit worldwide_organisation_path(worldwide_organisation)
  assert page.has_content?(worldwide_organisation.logo_formatted_name)
  assert page.has_css?(".description strong", text: "organisation")
  assert page.has_css?("#our-services h2", text: 'Passport renewals')
end

Then /^the "([^"]*)" logo should show correctly with the HMG crest$/ do |name|
  worldwide_organisation = WorldwideOrganisation.find_by_name(name)
  assert page.has_css?(".organisation-logo-stacked-single-identity", text: worldwide_organisation.logo_formatted_name)
end

Then /^I should see that it is part of the "([^"]*)"$/ do |sponsoring_organisation|
  assert page.has_css?(".sponsoring-organisation", sponsoring_organisation)
end

Then /^I should see the worldwide organisation listed on the page$/ do
  worldwide_organisation = WorldwideOrganisation.last
  within record_css_selector(worldwide_organisation) do
    assert page.has_content?(worldwide_organisation.name)
  end
end

Then /^I should see the worldwide location name "([^"]*)" on the worldwide organisation page$/ do |location_name|
  location = WorldLocation.find_by_name(location_name)
  worldwide_organisation = WorldwideOrganisation.last
  within record_css_selector(worldwide_organisation) do
    assert page.has_content?(location.name)
  end
end

Then /^I should see the worldwide organisation "([^"]*)" on the "([^"]*)" world location page$/ do |worldwide_organisation_name, location_name|
  location = WorldLocation.find_by_name(location_name)
  worldwide_organisation = WorldwideOrganisation.find_by_name(worldwide_organisation_name)
  visit world_location_path(location)
  within record_css_selector(worldwide_organisation) do
    assert page.has_content?(worldwide_organisation_name)
  end
end

When /^I update the worldwide organisation to set the name to "([^"]*)"$/ do |new_title|
  visit edit_admin_worldwide_organisation_path(WorldwideOrganisation.last)
  fill_in "Name", with: new_title
  click_on "Save"
end

When /^I delete the worldwide organisation$/ do
  @worldwide_organisation = WorldwideOrganisation.last
  visit edit_admin_worldwide_organisation_path(@worldwide_organisation)
  click_on "delete"
end

Then /^the worldwide organisation should not be visible from the public website$/ do
  assert_raises(ActiveRecord::RecordNotFound) do
    visit worldwide_organisation_path(@worldwide_organisation)
  end
end

Given /^a worldwide organisation "([^"]*)"$/ do |name|
  worg = create(:worldwide_organisation, name: name)
  worg.main_office = create(:worldwide_office, worldwide_organisation: worg, title: "Main office for #{name}")
end

Given /^a worldwide organisation "([^"]*)" exists for the world location "([^"]*)" with translations into "([^"]*)"$/ do |name, country_name, translation|
  country = create(:world_location, translated_into: [translation])
  create(:worldwide_organisation, name: name, world_locations: [country])
end

When /^I add an "([^"]*)" office for the home page with address, phone number, and some services$/ do |description|
  service1 = create(:worldwide_service, name: 'Dance lessons')
  service2 = create(:worldwide_service, name: 'Courses in advanced sword fighting')
  service3 = create(:worldwide_service, name: 'Beard grooming')

  visit admin_worldwide_organisation_worldwide_offices_path(WorldwideOrganisation.last)
  click_link "Add"
  fill_in_contact_details(title: description, feature_on_home_page: 'yes')
  select WorldwideOfficeType.all.sample.name, from: 'Office type'

  check service1.name
  check service3.name

  click_on "Save"
end

Then /^the "([^"]*)" office details should be shown on the public website$/ do |description|
  worldwide_org = WorldwideOrganisation.last
  visit worldwide_organisation_path(worldwide_org)
  worldwide_office = worldwide_org.offices.includes(:contact).where(contacts: {title: description}).first

  within "#{record_css_selector(worldwide_office)}.contact" do
    assert page.has_css?("h2", text: worldwide_office.contact.title)
    assert page.has_css?('.vcard', text: worldwide_office.contact.street_address)
    assert page.has_css?('.tel', text: worldwide_office.contact.contact_numbers.first.number)
  end
end

Given /^that the world location "([^"]*)" exists$/ do |country_name|
  create(:world_location, name: country_name)
end

Given /^the worldwide organisation "([^"]*)" exists$/ do |worldwide_organisation_name|
  create(:worldwide_organisation, name: worldwide_organisation_name, logo_formatted_name: worldwide_organisation_name)
  create(:organisation_type, name: "Other") #Needed for sorting
end

When /^I begin editing a new worldwide organisation "([^"]*)"$/ do |worldwide_organisation_name|
  visit new_admin_worldwide_organisation_path
  fill_in "Name", with: worldwide_organisation_name
  fill_in "Summary", with: "Worldwide organisation summary"
  fill_in "Description", with: "Worldwide **organisation** description"
end

When /^I select world location "([^"]*)"$/ do |world_location_name|
  select world_location_name, from: "World location"
end

When /^I click save$/ do
  click_on "Save"
end

Given /^a worldwide organisation "([^"]*)" with offices "([^"]*)" and "([^"]*)"$/ do |worldwide_organisation_name, contact1_title, contact2_title|
  worldwide_organisation = create(:worldwide_organisation, name: worldwide_organisation_name)
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation: worldwide_organisation, contact: create(:contact, title: contact1_title)))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation: worldwide_organisation, contact: create(:contact, title: contact2_title)))
end

When /^I choose "([^"]*)" to be the main office$/ do |contact_title|
  worldwide_office = WorldwideOffice.includes(:contact).where(contacts: {title: contact_title}).first
  visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  click_link "Offices"
  within record_css_selector(worldwide_office) do
    click_button 'Set as main office'
  end
end

Then /^the "([^"]*)" should be shown as the main office on the public website$/ do |contact_title|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_office = WorldwideOffice.includes(:contact).where(contacts: {title: contact_title}).first
  visit worldwide_organisation_path(worldwide_organisation)
  within "#{record_css_selector(worldwide_office)}.main" do
    assert page.has_content?(contact_title)
  end
end

Then /^he is listed as the supporting position of "([^"]*)" on the worldwide organisation page$/ do |position_name|
  worldwide_organisation = WorldwideOrganisation.last
  person = Person.last
  visit worldwide_organisation_path(worldwide_organisation)
  within record_css_selector(person) do
    assert page.has_content?(person.name)
    assert page.has_css?('p.role', text: position_name)
  end
end

Then /^I should see his picture on the worldwide organisation page$/ do
  visit worldwide_organisation_path(WorldwideOrganisation.last)
  person = Person.last

  within record_css_selector(person) do
    assert page.has_css?('img')
  end
end

Then /^I should not see his picture on the worldwide organisation page$/ do
  visit worldwide_organisation_path(WorldwideOrganisation.last)
  person = Person.last

  within record_css_selector(person) do
    refute page.has_css?('img')
  end
end

When /^I add default access information to the worldwide organisation$/ do
  visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  click_link 'Access and opening times'
  click_link 'Add default access information'
  fill_in 'Body', with: 'Default body information'
  click_button 'Save'
end

Then /^I should see the default access information on the public "([^"]*)" office page$/ do |office_name|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_office = Contact.where(title: office_name).first.contactable
  visit worldwide_organisation_path(worldwide_organisation)
  within record_css_selector(worldwide_office) do
    click_link 'Access and opening times'
  end

  within '.body' do
    assert page.has_content?('Default body information')
  end
end

Given /^a worldwide organisation "([^"]*)" with default access information$/ do |name|
  worldwide_organisation = create(:worldwide_organisation, name: name)
  create(:access_and_opening_times, accessible: worldwide_organisation, body: 'Default body information')
end

When /^I edit the default access information for the worldwide organisation$/ do
  worldwide_organisation = WorldwideOrganisation.last
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link 'Access and opening times'
  click_on 'Edit'
  fill_in 'Body', with: 'Edited body information'
  click_button 'Save'
end

Given /^the offices "([^"]*)" and "([^"]*)"$/ do |contact1_title, contact2_title|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation: worldwide_organisation, contact: create(:contact, title: contact1_title)))
  worldwide_organisation.add_office_to_home_page!(create(:worldwide_office, worldwide_organisation: worldwide_organisation, contact: create(:contact, title: contact2_title)))
end

When /^I give "([^"]*)" custom access information$/ do |office_name|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_office = Contact.where(title: office_name).first.contactable
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link 'Offices'
  within record_css_selector(worldwide_office) do
    click_on 'Customise'
  end

  fill_in 'Body', with: 'Custom body information'
  click_button 'Save'
end

Then /^I should see the custom access information on the public "([^"]*)" office page$/ do |office_name|
  worldwide_organisation = WorldwideOrganisation.last
  worldwide_office = Contact.where(title: office_name).first.contactable
  visit worldwide_organisation_path(worldwide_organisation)
  within record_css_selector(worldwide_office) do
    click_link 'Access and opening times'
  end

  within '.body' do
    assert page.has_content?('Custom body information')
  end
end

Then /^I should see the updated default access information$/ do
  assert page.has_css?('.govspeak p', text: 'Edited body information')
end


When /^I add a new translation to the worldwide organisation "([^"]*)" with:$/ do |name, table|
  worldwide_organisation = WorldwideOrganisation.find_by_name!(name)
  add_translation_to_worldwide_organisation(worldwide_organisation, table.rows_hash)
end

Then /^when viewing the worldwide organisation "([^"]*)" with the locale "([^"]*)" I should see:$/ do |name, locale, table|
  worldwide_organisation = WorldwideOrganisation.find_by_name!(name)
  translation = table.rows_hash

  visit world_location_path(worldwide_organisation.world_locations.first)
  click_link locale

  within record_css_selector(worldwide_organisation) do
    assert page.has_css?('.name', text: translation["name"]), "Name wasn't present on associated world location page"
  end

  click_link translation["name"]

  assert page.has_css?('.summary', text: translation["summary"]), "Summary wasn't present"
  assert page.has_css?('.description', text: translation["description"]), "Description wasn't present"
  assert page.has_css?('.content', text: translation["services"]), "Services wasn't present"
end

Given /^a worldwide organisation "([^"]*)" exists with a translation for the locale "([^"]*)"$/ do |name, native_locale_name|
  locale_code = Locale.find_by_language_name(native_locale_name).code
  country = create(:world_location, world_location_type: WorldLocationType::WorldLocation, translated_into: [locale_code])
  create(:worldwide_organisation, name: name, world_locations: [country], translated_into: [locale_code])
end

When /^I edit the "([^"]*)" translation for the worldwide organisation "([^"]*)" setting:$/ do |locale, name, table|
  edit_translation_for_worldwide_organisation(locale, name, table.rows_hash)
end

Then /^I should be able to associate "([^"]*)" with the worldwide organisation "([^"]*)"$/ do |edition_title, world_org_title|
  begin_editing_document edition_title
  select world_org_title, from: "edition_worldwide_organisation_ids"
  click_on "Save"
end

Given /^two worldwide organisations "([^"]*)" and "([^"]*)"$/ do |org1, org2|
  create(:worldwide_organisation, name: org1)
  create(:worldwide_organisation, name: org2)
end

When /^I visit the worldwide organisations index page$/ do
  visit worldwide_organisations_path
end

Then /^I should see an alphabetical list containing "([^"]*)" and "([^"]*)"$/ do |name1, name2|
  titles = [name1, name2].sort
  titles_by_letter = titles.group_by {|title| title[0].upcase}.sort_by {|letter, titles| letter}

  titles_by_letter.zip(page.all(".alphabetical-row")).each do |(letter, titles), row|
    assert row.has_css?('.alphabetical-list-letter', text: letter), "No letter #{letter} found"
    titles.each do |title|
      assert row.has_css?('li.worldwide_organisation', text: title)
    end
  end
end
