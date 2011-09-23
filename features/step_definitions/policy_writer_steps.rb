When /^I visit the new policy page$/ do
  visit new_admin_policy_path
end

When /^I write and save a policy called "([^"]*)" with body$/ do |title, body|
  When %{I write and save a policy called "#{title}" with body "#{body}"}
end

When /^I write and save a policy called "([^"]*)" with body "([^"]*)"$/ do |title, body|
  fill_in 'Title', with: title
  fill_in 'Policy', with: body
  click_button 'Save'
end

Then /^I should( not)? see the policy "([^"]*)" in my list of draft policies$/ do |invert, title|
  Given "I visit the list of draft policies"
  page_has_policy = page.has_css?('#draft_policies .policy', text: title)
  assert(invert.nil? ? page_has_policy : !page_has_policy)
end

Then /^I should see the policy "([^"]*)" written by "([^"]*)" in my list of draft policies$/ do |title, author|
  Then %{I should see the policy "#{title}" in my list of draft policies}
  assert page.has_css?('#draft_policies .author', text: author)
end

Given /^I have written a policy called "([^"]*)"$/ do |title|
  When "I visit the new policy page"
  And %{I write and save a policy called "#{title}" with body "Blah blah blah"}
end

Given /^I visit the list of draft policies$/ do
  visit admin_policies_path
end

When /^I change the policy "([^"]*)" to "([^"]*)"$/ do |old_title, new_title|
  click_link "Edit #{old_title}"
  fill_in 'Title', with: new_title
  click_button 'Save'
end

When /^I click cancel$/ do
  click_link "cancel"
end

Given /^I click edit for the policy "([^"]*)"$/ do |policy_title|
  click_link "Edit #{policy_title}"
end

Given /^I click create new policy$/ do
  click_link "Draft new Policy"
end

Given /^I submit the policy for the second set of eyes$/ do
  check 'Submit to second set of eyes'
  click_button 'Save'
end