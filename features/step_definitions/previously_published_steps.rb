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
  select "July",  from: "edition_first_published_at_2i"
  select "1",    from: "edition_first_published_at_3i"
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
  assert page.has_content?("You must specify whether the document has been published before"),
    "Previously published option validation message not found"
end

Then(/^I see a validation error for the future date$/) do
  assert page_has_first_published_at_in_future_error_message,
    "Previously published (first_published_at) validation message not found"
end

Then(/^I see a validation error for the missing publication date$/) do
  assert page.has_content?("First published at can't be blank"),
    "First published can't be blank validation message found"
end

Then(/^I should not see a validation error on the previously published date$/) do
  refute page_has_first_published_at_in_future_error_message,
    "First published at in the future validation message found"
end

def page_has_first_published_at_in_future_error_message
  page.has_content?("First published at can't be set to a future date")
end

