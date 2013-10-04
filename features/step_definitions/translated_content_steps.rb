# encoding: utf-8

Given /^I am viewing a world location that is translated$/ do
  world_location = create(:world_location, translated_into: [:fr])
  worldwide_organisation = create(:worldwide_organisation,
    world_locations: [world_location],
    name: "en-organisation", summary: "en-summary",
    translated_into: {fr: {name: "fr-organisation", summary: "fr-summary"}}
  )
  visit world_location_path(world_location)
  click_link "Français"
end

When /^I visit a world organisation associated with that locale that is also translated$/ do
  click_link "fr-organisation"
end

Then /^I should see the translation of that world organisation$/ do
  assert page.has_css?(".summary", text: "fr-summary"), "expected to see the french summary, but didn't"
end

Given /^I have drafted a translatable document "([^"]*)"$/ do |title|
  begin_drafting_document type: "worldwide_priority", title: title
  click_button "Save"
end

When /^I add a french translation "([^"]*)" to the "([^"]*)" document$/ do |french_title, english_title|
  visit admin_edition_path(Edition.find_by_title!(english_title))
  click_link "open-add-translation-modal"
  select "Français", from: "Locale"
  click_button "Add translation"
  fill_in "Title", with: french_title
  fill_in "Summary", with: "French summary"
  fill_in "Body", with: "French body"
  click_button "Save"
end

Then /^I should see on the admin edition page that "([^"]*)" has a french translation "([^"]*)"$/ do |english_title, french_title|
  visit admin_edition_path(Edition.find_by_title!(english_title))
  assert page.has_text?(french_title)
end

Given(/^the organisation "(.*?)" has a contact "(.*?)"$/) do |organisation_name, contact_title|
  organisation = create(:organisation, name: organisation_name, translated_into: :cy)
  create(:contact, title: contact_title, country: create(:world_location),
         street_address: '123 The Avenue', contactable: organisation)
end

When(/^I add a welsh translation "(.*?)" to the "(.*?)" contact$/) do |welsh_title, english_title|
  contact = Contact.where(title: english_title).first
  visit admin_organisation_contacts_path(contact.contactable)
  click_link "open-add-translation-modal"
  select "Cymraeg", from: "Locale"
  click_button "Add translation"
  fill_in "Title", with: welsh_title
  fill_in "Recipient", with: "Welsh recipient"
  fill_in "Street address", with: "Welsh street address"
  click_button "Save"
end

Then(/^I should see on the admin organisation contacts page that "(.*?)" has a welsh translation "(.*?)"$/) do |english_title, welsh_title|
  contact = Contact.where(title: english_title).first
  visit admin_organisation_contacts_path(contact.contactable)
  assert page.has_text?("Cymraeg (Welsh) translation")
  assert page.has_text?(welsh_title)
end
