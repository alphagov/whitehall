When /^I visit the new policy page$/ do
  visit new_admin_edition_path
end

When /^I write a policy called "([^"]*)" with body$/ do |title, body|
  When %{I write a policy called "#{title}" with body "#{body}"}
end

When /^I write and save a policy called "([^"]*)" with body$/ do |title, body|
  When %{I write and save a policy called "#{title}" with body "#{body}"}
end

When /^I request that "([^"]*)" fact checks the policy$/ do |email_address|
  fill_in "Email address", :with => email_address
  click_button "Request fact checking"
end

When /^I write and save a policy called "([^"]*)" with body "([^"]*)"$/ do |title, body|
  When %{I write a policy called "#{title}" with body "#{body}"}
  click_button 'Save'
end

When /^I write a policy called "([^"]*)" with body "([^"]*)"$/ do |title, body|
  fill_in 'Title', with: title
  fill_in 'Policy', with: body
end

Then /^I should( not)? see the policy "([^"]*)" in my list of draft policies$/ do |invert, title|
  Given "I visit the list of draft policies"
  page_has_policy = page.has_css?('.edition', text: title)
  assert(invert.nil? ? page_has_policy : !page_has_policy)
end

Then /^I should see the policy "([^"]*)" written by "([^"]*)" in my list of draft policies$/ do |title, author|
  Then %{I should see the policy "#{title}" in my list of draft policies}
  assert page.has_css?('.edition .author', text: author)
end

Given /^I have drafted a policy$/ do
  Given %{I have drafted a policy called "Whatever"}
end

Given /^I have drafted a policy called "([^"]*)"$/ do |title|
  When "I visit the new policy page"
  And %{I write and save a policy called "#{title}" with body "Blah blah blah"}
end

Given /^I visit the list of draft policies$/ do
  visit admin_editions_path
end

Given /^I visit the list of submitted policies$/ do
  visit submitted_admin_editions_path
end

When /^I change the policy "([^"]*)" to "([^"]*)"$/ do |old_title, new_title|
  click_link old_title
  click_link "Edit"
  fill_in 'Title', with: new_title
  click_button 'Save'
end

When /^I click cancel$/ do
  click_link "cancel"
end

Given /^I click edit for the policy "([^"]*)"$/ do |policy_title|
  click_link policy_title
  click_link "Edit"
end

Given /^I click create new policy$/ do
  click_link "Draft new Policy"
end

Given /^I submit the policy for the second set of eyes$/ do
  click_link 'cancel'
  click_button 'Submit to 2nd pair of eyes'
end

When /^another user changes the body for "([^"]*)" to "([^"]*)"$/ do |title, new_body|
  policy = Edition.find_by_title(title)
  policy.update_attributes(:body => new_body)
end

When /^I save the policy$/ do
  click_button 'Save'
end

Then /^I should be alerted that the policy has been changed$/ do
  Then %{I should be alerted "This policy has been edited since you viewed it; you are now viewing the latest version"}
end

Then /^I should be alerted that the policy has been saved while I was editing$/ do
  Then %{I should be alerted "This policy has been saved since you opened it. Your version appears on the left and the latest version appears on the right. Please incorporate any relevant changes into your version and then save it."}
end

Then /^I should see the "([^"]*)" version and the "([^"]*)" version of the policy side\-by\-side$/ do |new_title, latest_title|
  assert page.has_css?(".conflicting.new #edition_title", value: new_title)
  assert page.has_css?(".conflicting.latest #edition_title[disabled]", value: latest_title)
end

When /^I change my version of the policy title to "([^"]*)"$/ do |new_title|
  fill_in 'Title', with: new_title
end

Then /^I should be notified that the policy has been saved successfully$/ do
  Then %{I should be notified "The policy has been saved"}
end

Then /^I should see the fact checking feedback "([^"]*)"$/ do |comments|
  assert page.has_css?(".fact_check_request .comments", :text => comments)
end