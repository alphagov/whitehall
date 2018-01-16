When(/^I visit the history page$/) do
  visit histories_path
end

Then(/^I should see historic information$/) do
  assert page.has_content?("History of the UK government")
end

When(/^I visit the "([^"]*)" page$/) do |path|
  visit history_path(path.parameterize)
end

Then(/^I should see historic information about "([^"]*)"$/) do |name|
  assert page.has_content?(name.titlecase)
end
