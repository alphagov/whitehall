When(/^I start editing the needs from the .*? page$/) do
  click_on 'Add/remove needs'
end

When(/^I choose the first need in the dropdown$/) do
  option = first('#need_ids option').text
  select option, from: 'need_ids'
  click_button 'Save needs'
end

Then(/^I should see the first need in the list of associated needs$/) do
  page.find("h2:contains('Associated user needs')")
  assert_equal first("td.description").text, "As a x, I need to y, So that z"
end
