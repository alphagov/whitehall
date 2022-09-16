Given(/^I start editing the speech "([^"]*)" changing the title to "([^"]*)"$/) do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
end

Given(/^"([^"]*)" submitted a speech "([^"]*)" with body "([^"]*)"$/) do |author, title, body|
  step %(I am a writer called "#{author}")
  visit new_admin_speech_path
  begin_drafting_speech title: title, body: body
  click_button "Save"
  click_button "Submit"
end

Given(/^a published speech "([^"]*)" by "([^"]*)" on "([^"]*)" at "([^"]*)"$/) do |title, ministerial_role, delivered_on, location|
  role_appointment = MinisterialRole.all.detect { |mr| mr.name == ministerial_role }.current_role_appointment
  create(:published_speech, title:, role_appointment:, delivered_on: Date.parse(delivered_on), location:)
end

Given(/^a published speech exists$/) do
  @speech = create(:published_speech)
end

When(/^I edit the speech "([^"]*)" changing the title to "([^"]*)"$/) do |original_title, new_title|
  speech = Speech.find_by!(title: original_title)
  visit admin_edition_path(speech)
  click_link "Edit draft"
  fill_in "Title", with: new_title
  click_button "Save"
end

When(/^I edit the speech changing the title to "([^"]*)"$/) do |new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

When(/^I visit the list of speeches awaiting review$/) do
  visit admin_editions_path(state: :submitted)
end

When(/^I create a new edition of the published speech$/) do
  visit admin_editions_path(state: :published)
  click_link Speech.published.last.title
  click_button "Create new edition"
end

When(/^I draft a new speech "([^"]*)"$/) do |title|
  begin_drafting_speech title: title
  click_button "Save"
end

When(/^I visit the speech "([^"]*)"$/) do |title|
  speech = Speech.find_by!(title:)
  visit public_document_path(speech)
end

Then(/^I should see the speech was delivered on "([^"]*)" at "([^"]*)"$/) do |delivered_on, location|
  expect(page).to have_selector(".delivered-on", text: delivered_on)
  expect(page).to have_selector(".location", text: location)
end

When(/^I draft a new authored article "([^"]*)"$/) do |title|
  begin_drafting_speech title: title
  select "Authored article", from: "Speech type"
end

Then(/^I should be able to choose who wrote the article$/) do
  select "Colonel Mustard, Attorney General", from: "Writer"
end

Then(/^I should be able to choose the date it was written on$/) do
  select_date 1.day.ago.to_s, from: "Written on"
end

Then(/^I cannot choose a location for the article$/) do
  expect(page).to_not have_content("#edition_location")
end

Then(/^it should be shown as an authored article in the admin screen$/) do
  click_button "Save"
  expect(page).to have_content("Authored article")
end

Then(/^I should see who wrote it clearly labelled in the metadata$/) do
  expect(page).to have_selector("dt", text: "Written on:")
end

Then(/^I should see that "(.*?)" is listed on the page$/) do |title|
  expect(page).to have_content(title)
end
