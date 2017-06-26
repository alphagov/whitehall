# encoding: utf-8

Given /^a worldwide organisation that is translated exists$/ do
  world_location = create(:world_location)
  worldwide_organisation = create(:worldwide_organisation,
    world_locations: [world_location],
    name: "en-organisation",
    translated_into: {fr: {name: "fr-organisation"}}
  )
  create(:about_corporate_information_page, organisation: nil,
         worldwide_organisation: worldwide_organisation,  summary: "en-summary",
         translated_into: {fr: {summary: "fr-summary"}}
  )
end

When /^I visit the world organisation that is translated$/ do
  visit worldwide_organisation_path(WorldwideOrganisation.last, locale: "fr")
end

Then /^I should see the translation of that world organisation$/ do
  assert page.has_css?(".summary", text: "fr-summary"), "expected to see the french summary, but didn't"
end

Given /^I have drafted a translatable document "([^"]*)"$/ do |title|
  begin_drafting_document type: "case_study", title: title, previously_published: false
  click_button "Save"
end

When /^I add a french translation "([^"]*)" to the "([^"]*)" document$/ do |french_title, english_title|
  visit admin_edition_path(Edition.find_by!(title: english_title))
  click_link "open-add-translation-modal"
  select "Français", from: "Locale"
  click_button "Add translation"
  fill_in "Title", with: french_title
  fill_in "Summary", with: "French summary"
  fill_in "Body", with: "French body"
  click_button "Save"
end

Then /^I should see on the admin edition page that "([^"]*)" has a french translation "([^"]*)"$/ do |english_title, french_title|
  visit admin_edition_path(Edition.find_by!(title: english_title))
  assert page.has_text?(french_title)
end

Given(/^the organisation "(.*?)" is translated into Welsh and has a contact "(.*?)"$/) do |organisation_name, contact_title|
  organisation = create(:organisation, name: organisation_name, translated_into: :cy)
  contact = create(:contact, title: contact_title, country: create(:world_location),
                   street_address: '123 The Avenue', contactable: organisation)
  create(:contact_number, contact: contact,
         label: 'English phone', number: '0123456789')
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
  assert page.has_text?("Cymraeg (Welsh) translation")
  assert page.has_text?(welsh_title)
  assert page.has_text?("9876543210")
end

Given(/^the world organisation "(.*?)" is translated into French and has an office "(.*?)"$/) do |organisation_name, office_name|
  organisation = create(:worldwide_organisation, name: organisation_name, translated_into: :fr)
  contact = create(:contact, title: office_name, country: create(:world_location),
                   street_address: "123 The Avenue")
  create(:contact_number, contact: contact, label: "English phone", number: "0123456789")
  office = create(:worldwide_office, worldwide_organisation: organisation, contact: contact)
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
  assert page.has_text?("Français (French) translation")
  assert page.has_text?(french_title)
  assert page.has_text?("9876543210")
end
