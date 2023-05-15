Given(/^I start editing the speech "([^"]*)" changing the title to "([^"]*)"$/) do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
end

Given(/^"([^"]*)" submitted a speech "([^"]*)" with body "([^"]*)"$/) do |author, title, body|
  step %(I am a writer called "#{author}")
  visit new_admin_speech_path
  begin_drafting_speech(title:, body:)
  click_button "Save and continue"
  click_button "Update tags"
  click_button "Submit"
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

When(/^I draft a new speech "([^"]*)"$/) do |title|
  begin_drafting_speech(title:)
  click_button "Save"
end

When(/^I draft a new authored article "([^"]*)"$/) do |title|
  begin_drafting_speech(title:)
  select "Authored article", from: "Speech type"
end

Then(/^I should be able to choose who wrote the article$/) do
  if using_design_system?
    choose "Writer has a profile on GOV.UK"
    select "Colonel Mustard, Attorney General", from: "edition[role_appointment_id]"
  else
    select "Colonel Mustard, Attorney General", from: "Writer"
  end
end

Then(/^I should be able to choose the date it was written on$/) do
  if using_design_system?
    within "#edition_delivered_on" do
      fill_in_date_and_time_field(1.day.ago.to_s)
    end
  else
    select_date 1.day.ago.to_s, from: "Written on"
  end
end

Then(/^I cannot choose a location for the article$/) do
  expect(page).to_not have_content("#edition_location")
end

Then(/^I should see that "(.*?)" is listed on the page$/) do |title|
  expect(page).to have_content(title)
end
