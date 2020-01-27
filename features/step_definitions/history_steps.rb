When(/^I visit the history page$/) do
  visit histories_path
end

Then(/^I should see historic information$/) do
  assert_text "History of the UK government"
end

When(/^I visit the "([^"]*)" page$/) do |path|
  visit history_path(path.parameterize)
end

Then(/^I should see historic information about "([^"]*)"$/) do |name|
  assert_text name.titlecase
end
