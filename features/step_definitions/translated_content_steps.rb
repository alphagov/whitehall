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

