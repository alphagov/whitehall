When /^I create a worldwide office "([^"]*)" sponsored by the "([^"]*)" with a summary, description and services$/ do |name, sponsoring_organisation|
  visit new_admin_worldwide_office_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  fill_in "Summary", with: "Worldwide office summary"
  fill_in "Description", with: "Worldwide **office** description"
  fill_in "Services", with: "## Passport renewals\n\nYou can renew your passport"
  select sponsoring_organisation, from: "Sponsoring organisations"
  click_on "Save"
end

When /^I create a new worldwide office "([^"]*)" in "([^"]*)"$/ do |name, location|
  visit new_admin_worldwide_office_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  fill_in "Summary", with: "Worldwide office summary"
  fill_in "Description", with: "Worldwide **office** description"
  select location, from: "World location"
  click_on "Save"
end

When /^I create a new worldwide office "([^"]*)" in  "([^"]*)" sponsored by the "([^"]*)"$/ do |name, location, sponsoring_organisation|
  visit new_admin_worldwide_office_path
  fill_in "Name", with: name
  fill_in "Logo formatted name", with: name
  fill_in "Summary", with: "Worldwide office summary"
  fill_in "Description", with: "Worldwide **office** description"
  select location, from: "World location"
  select sponsoring_organisation, from: "Sponsoring organisations"
  click_on "Save"
end


Then /^I should see the(?: updated)? worldwide office information on the public website$/ do
  office = WorldwideOffice.last
  visit worldwide_office_path(office)
  assert page.has_content?(office.logo_formatted_name)
  assert page.has_css?(".description strong", text: "office")
  assert page.has_css?("#our-services h2", text: 'Passport renewals')
end

Then /^the "([^"]*)" logo should show correctly with the HMG crest$/ do |name|
  office = WorldwideOffice.find_by_name(name)
  assert page.has_css?(".organisation-logo-stacked-single-identity", text: office.logo_formatted_name)
end

Then /^I should see that it is part of the "([^"]*)"$/ do |sponsoring_organisation|
  assert page.has_css?(".sponsoring-organisation", sponsoring_organisation)
end

Then /^I should see the worldwide office listed on the page$/ do
  office = WorldwideOffice.last
  within record_css_selector(office) do
    assert page.has_content?(office.name)
  end
end

Then /^I should see the worldwide office "([^"]*)" on the "([^"]*)" world location page$/ do |office_name, location_name|
  location = WorldLocation.find_by_name(location_name)
  office = WorldwideOffice.find_by_name(office_name)
  visit world_location_path(location)
  within record_css_selector(office) do
    assert page.has_content?(office_name)
  end
end

When /^I update the worldwide office to set the name to "([^"]*)"$/ do |new_title|
  visit edit_admin_worldwide_office_path(WorldwideOffice.last)
  fill_in "Name", with: new_title
  click_on "Save"
end

When /^I delete the worldwide office$/ do
  @office = WorldwideOffice.last
  visit edit_admin_worldwide_office_path(@office)
  click_on "delete"
end

Then /^the worldwide office should not be visible from the public website$/ do
  assert_raises(ActiveRecord::RecordNotFound) do
    visit worldwide_office_path(@office)
  end
end

Given /^a worldwide office "([^"]*)"$/ do |name|
  create(:worldwide_office, name: name)
end

Given /^a worldwide office "([^"]*)" exists for the country "([^"]*)" with translations into "([^"]*)"$/ do |name, country_name, translation|
  country = create(:country, translated_into: [translation])
  create(:worldwide_office, name: name, world_locations: [country])
end

When /^I add a "([^"]*)" social media link "([^"]*)"$/ do |social_service, url|
  visit admin_worldwide_office_path(WorldwideOffice.last)
  click_link "Social Media Accounts"
  click_link "Add"
  select social_service, from: "Service"
  fill_in "Url", with: url
  click_on "Save"
end

Then /^the social link should be shown on the public website$/ do
  visit worldwide_office_path(WorldwideOffice.last)
  assert page.has_css?(".social-media-accounts")
end

When /^I add an "([^"]*)" contact with address and phone number$/ do |description|
  visit contacts_admin_worldwide_office_path(WorldwideOffice.last)
  click_link "Add"
  fill_in "Title", with: description
  fill_in "Street address", with: "address1\naddress2"
  fill_in "Postal code", with: "12345-123"
  fill_in "Email", with: "foo@bar.com"
  fill_in "Label", with: "Main phone number"
  fill_in "Number", with: "+22 (0) 111 111-111"
  select "United Kingdom", from: "Country"
  click_on "Save"
end

Then /^the "([^"]*)" details should be shown on the public website$/ do |description|
  visit worldwide_office_path(WorldwideOffice.last)
  assert page.has_css?(".contact h2", text: description)
end

Given /^that the world location "([^"]*)" exists$/ do |country_name|
  create(:country, name: country_name)
end

Given /^the worldwide office "([^"]*)" exists$/ do |office_name|
  create(:worldwide_office, name: office_name, logo_formatted_name: office_name)
end

When /^I begin editing a new worldwide office "([^"]*)"$/ do |office_name|
  visit new_admin_worldwide_office_path
  fill_in "Name", with: office_name
  fill_in "Summary", with: "Worldwide office summary"
  fill_in "Description", with: "Worldwide **office** description"
end

When /^I select world location "([^"]*)"$/ do |world_location_name|
  select world_location_name, from: "World location"
end

When /^I click save$/ do
  click_on "Save"
end

Given /^a worldwide office "([^"]*)" with contacts "([^"]*)" and "([^"]*)"$/ do |office_name, contact1_title, contact2_title|
  office = create(:worldwide_office, name: office_name)
  create(:contact, title: contact1_title, contactable: office)
  create(:contact, title: contact2_title, contactable: office)
end

When /^I choose "([^"]*)" to be the main contact$/ do |contact_title|
  contact = Contact.find_by_title(contact_title)
  visit admin_worldwide_office_path(WorldwideOffice.last)
  click_link "Contacts"
  within record_css_selector(contact) do
    click_button 'Set as main contact'
  end
end

Then /^the "([^"]*)" should be shown as the main contact on the public website$/ do |contact_title|
  office = WorldwideOffice.last
  contact = Contact.find_by_title(contact_title)
  visit worldwide_office_path(office)
  within "#{record_css_selector(contact)}.main" do
    assert page.has_content?(contact.title)
  end
end

Then /^he is listed as the supporting position of "([^"]*)" on the worldwide office page$/ do |position_name|
  office = WorldwideOffice.last
  person = Person.last
  visit worldwide_office_path(office)
  within record_css_selector(person) do
    assert page.has_content?(person.name)
    assert page.has_css?('p.role', text: position_name)
  end
end

Then /^I should see his picture on the worldwide office page$/ do
  visit worldwide_office_path(WorldwideOffice.last)
  person = Person.last

  within record_css_selector(person) do
    assert page.has_css?('img')
  end
end

Then /^I should not see his picture on the worldwide office page$/ do
  visit worldwide_office_path(WorldwideOffice.last)
  person = Person.last

  within record_css_selector(person) do
    refute page.has_css?('img')
  end
end

def add_translation_to_worldwide_office(worldwide_office, translation)
  translation = translation.stringify_keys
  visit admin_worldwide_offices_path
  within record_css_selector(worldwide_office) do
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

def edit_translation_for_worldwide_office(locale, name, translation)
  location = WorldwideOffice.find_by_name!(name)
  visit admin_worldwide_offices_path
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

When /^I add a new translation to the worldwide office "([^"]*)" with:$/ do |name, table|
  worldwide_office = WorldwideOffice.find_by_name!(name)
  add_translation_to_worldwide_office(worldwide_office, table.rows_hash)
end

Then /^when viewing the worldwide office "([^"]*)" with the locale "([^"]*)" I should see:$/ do |name, locale, table|
  worldwide_office = WorldwideOffice.find_by_name!(name)
  translation = table.rows_hash

  visit world_location_path(worldwide_office.world_locations.first, locale: locale)
  within record_css_selector(worldwide_office) do
    assert page.has_css?('.name', text: translation["name"]), "Name wasn't present on associated world location page"
  end

  # until links preserve locale, we cannot do this:
  #     click_link translation["name"]
  # so instead, we check the link is at least present with the right text, and then visit it with the right locale
  assert page.has_link?(translation["name"], href: worldwide_office_path(worldwide_office))
  visit worldwide_office_path(worldwide_office, locale: locale)

  assert page.has_css?('.summary', text: translation["summary"]), "Summary wasn't present"
  assert page.has_css?('.description', text: translation["description"]), "Description wasn't present"
  assert page.has_css?('.content', text: translation["services"]), "Services wasn't present"
end

Given /^a worldwide office "([^"]*)" exists with a translation for the locale "([^"]*)"$/ do |name, native_locale_name|
  locale_code = Locale.find(native_locale_name).code
  country = create(:world_location, world_location_type: WorldLocationType::Country, translated_into: [locale_code])
  create(:worldwide_office, name: name, world_locations: [country], translated_into: [locale_code])
end

When /^I edit the "([^"]*)" translation for the worldwide office "([^"]*)" setting:$/ do |locale, name, table|
  edit_translation_for_worldwide_office(locale, name, table.rows_hash)
end
