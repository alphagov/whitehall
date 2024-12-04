Given(/^the date is 2018-06-07$/) do
  Timecop.freeze "2018-06-07"
end

When(/^I start a new case study$/) do
  visit "/government/admin/case-studies/new"
end

And(/^I click save$/) do
  click_button "Save"
end

And(/^I click confirm$/) do
  click_button "Confirm"
end

And(/^I select a previously published date in the future$/) do
  check "This document has previously been published on another website"
  within "#edition_previously_published" do
    fill_in_date_fields("1 July 2018")
  end
end

And(/^I select that this document has been previously published$/) do
  check "This document has previously been published on another website"
end

And(/^I select a previously published date in the past$/) do
  check "This document has previously been published on another website"
  within "#edition_previously_published" do
    fill_in_date_fields("1 February 2017")
  end
end

Then(/^I do not see a validation error for the 'previously published' option$/) do
  expect(page).not_to have_content("You must specify whether the document has been published before")
end

Then(/^I see a validation error for the future date$/) do
  expect(page).to have_content("First published date must be between 1/1/1900 and the present")
end

Then(/^I see a validation error for the missing publication date$/) do
  expect(page).to have_content("Enter a first published date")
end

Then(/^I should not see a validation error on the previously published date$/) do
  expect(page).to_not have_content("First published date must be between 1/1/1900 and the present")
end
