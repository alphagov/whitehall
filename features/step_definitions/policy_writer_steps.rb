Given /^I visit the list of draft policies$/ do
  visit admin_editions_path
end

Given /^I click edit for the policy "([^"]*)"$/ do |policy_title|
  click_link policy_title
  click_link "Edit"
end

Given /^I submit the policy for the second set of eyes$/ do
  click_button 'Submit to 2nd pair of eyes'
end

When /^I visit the new policy page$/ do
  visit new_admin_edition_path
end

When /^I request that "([^"]*)" fact checks the policy "([^"]*)"$/ do |email, title|
  edition = Edition.find_by_title(title)
  assert edition.document.is_a?(Policy)
  visit admin_editions_path
  within(record_css_selector(edition)) do
    click_link title
  end
  click_link 'Edit'
  within("#new_fact_check_request") do
    fill_in "Email address", with: email
    click_button "Request fact checking"
  end
end

When /^I write and save a policy called "([^"]*)" with body "([^"]*)"$/ do |title, body|
  When %{I write a policy called "#{title}" with body "#{body}"}
  click_button 'Save'
end

When /^I write a policy called "([^"]*)" with body "([^"]*)"$/ do |title, body|
  fill_in 'Title', with: title
  fill_in 'Policy', with: body
end

Then /^I should see the fact checking feedback "([^"]*)"$/ do |comments|
  assert page.has_css?(".fact_check_request .comments", text: comments)
end