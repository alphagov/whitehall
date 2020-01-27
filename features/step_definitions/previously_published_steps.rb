Given(/^the date is 2018-06-07$/) do
  Timecop.freeze "2018-06-07"
end

When(/^I start a new case study$/) do
  visit "/government/admin/case-studies/new"
end

And(/^I click save$/) do
  click_button "Save"
end

And(/^I select a previously published date in the future$/) do
  choose "has previously been published on another website."
  select "2018", from:"edition_first_published_at_1i"
  select "July", from: "edition_first_published_at_2i"
  select "1", from: "edition_first_published_at_3i"
end

And(/^I select that this document has been previously published$/) do
  choose "has previously been published on another website."
end

And(/^I select a previously published date in the past$/) do
  choose "has previously been published on another website."
  select "2017",      from: "edition_first_published_at_1i"
  select "February",  from: "edition_first_published_at_2i"
  select "1",         from: "edition_first_published_at_3i"
end

Then(/^I see a validation error for the 'previously published' option$/) do
  assert_text "You must specify whether the document has been published before"
end

Then(/^I see a validation error for the future date$/) do
  assert_text "First published at can't be set to a future date"
end

Then(/^I see a validation error for the missing publication date$/) do
  assert_text "First published at can't be blank"
end

Then(/^I should not see a validation error on the previously published date$/) do
  assert_no_text "First published at can't be set to a future date"
end
