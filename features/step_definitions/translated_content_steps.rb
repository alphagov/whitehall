Given(/^a worldwide organisation that is translated exists$/) do
  world_location = create(:world_location, active: true)
  create(
    :worldwide_organisation,
    world_locations: [world_location],
    name: "en-organisation",
    summary: "en-summary",
    translated_into: { fr: { name: "fr-organisation", summary: "fr-summary", body: "fr-body" } },
  )
end

When(/^I visit the world organisation that is translated$/) do
  visit WorldwideOrganisation.last.public_path(locale: "fr")
end

Then(/^I should see the translation of that world organisation$/) do
  expect(page).to have_selector(".worldwide-org-summary", text: "fr-summary")
  expect(page).to have_selector(".worldwide-org-description", text: "fr-body")
end

Given(/^I have drafted a translatable document "([^"]*)"$/) do |title|
  begin_drafting_document type: "case_study", title:, previously_published: false
  click_button "Save"
end

When(/^I add a french translation "([^"]*)" to the "([^"]*)" document$/) do |french_title, english_title|
  visit admin_edition_path(Edition.find_by!(title: english_title))
  click_link "Add translation"

  select "Français", from: "Choose language"
  click_button "Next"
  fill_in "Translated title (required)", with: french_title
  fill_in "Translated summary (required)", with: "French summary"
  fill_in "Translated body (required)", with: "French body"
  click_button "Save"
end

Then(/^I should see on the admin edition page that "([^"]*)" has a french translation "([^"]*)"$/) do |english_title, french_title|
  visit admin_edition_path(Edition.find_by!(title: english_title))
  expect(page).to have_content(french_title)
end

Given(/^the organisation "(.*?)" is translated into Welsh and has a contact "(.*?)"$/) do |organisation_name, contact_title|
  organisation = create(:organisation, name: organisation_name, translated_into: :cy)
  contact = create(
    :contact,
    title: contact_title,
    country: create(:world_location, active: true),
    street_address: "123 The Avenue",
    contactable: organisation,
  )
  create(
    :contact_number,
    contact:,
    label: "English phone",
    number: "0123456789",
  )
end

When(/^I add a welsh translation "(.*?)" to the "(.*?)" contact$/) do |welsh_title, english_title|
  contact = Contact.find_by(title: english_title)
  visit admin_organisation_contacts_path(contact.contactable)
  click_link "Add translation"
  select "Cymraeg", from: "Locale"
  click_button "Add translation"
  fill_in "Title", with: welsh_title
  fill_in "Recipient", with: "Welsh recipient"
  fill_in "Street address", with: "Welsh street address"
  fill_in "Number", with: "9876543210"
  click_button "Save"
end

Then(/^I should see on the admin organisation contacts page that "(.*?)" has a welsh translation "(.*?)"$/) do |english_title, welsh_title|
  contact = Contact.find_by(title: english_title)
  visit admin_organisation_contacts_path(contact.contactable)
  expect(page).to have_content("Cymraeg (Welsh) translation")
  expect(page).to have_content(welsh_title)
  expect(page).to have_content("9876543210")
end

Given(/^the world organisation "(.*?)" is translated into French and has an office "(.*?)"$/) do |organisation_name, office_name|
  organisation = create(:worldwide_organisation, name: organisation_name, translated_into: :fr)
  contact = create(
    :contact,
    title: office_name,
    country: create(:world_location, active: true),
    street_address: "123 The Avenue",
  )
  create(:contact_number, contact:, label: "English phone", number: "0123456789")
  create(:worldwide_office, worldwide_organisation: organisation, contact:)
end

When(/^I add a french translation "(.*?)" to the "(.*?)" office$/) do |french_title, english_title|
  office = Contact.find_by(title: english_title).contactable
  visit admin_worldwide_organisation_worldwide_offices_path(office.worldwide_organisation)
  click_link "Add translation"
  select "Français", from: "Locale"
  click_button "Add translation"
  fill_in "Title", with: french_title
  fill_in "Recipient", with: "French recipient"
  fill_in "Street address", with: "French street address"
  fill_in "Number", with: "9876543210"
  click_button "Save"
end

Then(/^I should see on the admin world organisation offices page that "(.*?)" has a french translation "(.*?)"$/) do |english_title, french_title|
  office = Contact.find_by(title: english_title).contactable
  visit admin_worldwide_organisation_worldwide_offices_path(office.worldwide_organisation)
  expect(page).to have_content("Français (French) translation")
  expect(page).to have_content(french_title)
  expect(page).to have_content("9876543210")
end
