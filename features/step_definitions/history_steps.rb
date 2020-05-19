When(/^I visit the history page$/) do
  visit histories_path
end

Then(/^I should see historic information$/) do
  assert_text "History of the UK government"
end
