Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am logged in as "#{author}"}
  And %{I visit the new policy page}
  And %{I write and save a policy called "#{title}" with body "#{body}"}
  And %{I submit the policy for the second set of eyes}
end

Then /^the policy "([^"]*)" should( not)? be visible to the public$/ do |policy_title, invert|
  visit policies_path
  published_policy_selector = ["#published_policies .policy .title", text: policy_title]
  if invert.nil?
    assert page.has_css?(*published_policy_selector)
    click_link policy_title
    assert page.has_css?(".policy_document .title", text: policy_title)
  else
    assert page.has_no_css?(*published_policy_selector)
  end
end

When /^another user changes the title from "([^"]*)" to "([^"]*)"$/ do |old_title, new_title|
  policy = Edition.find_by_title(old_title)
  policy.update_attributes(:title => new_title)
end

When /^I create a new edition of the published policy$/ do
  Given %{I visit the list of published policies}
  click_button 'Create new draft'
end

Given /^I visit the list of published policies$/ do
  visit published_admin_editions_path
end

When /^I edit the new edition$/ do
  fill_in 'Title', with: "New title"
  fill_in 'Policy', with: "New policy"
  click_button 'Save'
end

Then /^the published policy should remain unchanged$/ do
  visit policy_path(@edition.policy)
  assert page.has_css?('.policy_document .title', text: @edition.title)
  assert page.has_css?('.policy_document .body', text: @edition.body)
end

Given /^"([^"]*)" has received an email requesting they fact check a draft policy titled "([^"]*)"$/ do |email, title|
  edition = FactoryGirl.create(:draft_edition, :title => title)
  Notifications.fact_check(edition, email).deliver
end

When /^"([^"]*)" clicks the email link to the draft policy$/ do |email|
  When %{I open the last email sent to "#{email}"}
  And %{I click the first link in the email}
end

Then /^they should see the draft policy titled "([^"]*)"$/ do |title|
  edition = Edition.find_by_title(title)
  assert page.has_css?('.policy .title', :text => edition.title)
  assert page.has_css?('.policy .body', :text => edition.body)
end