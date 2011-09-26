When /^I visit the list of policies awaiting review$/ do
  visit submitted_admin_editions_path
end

When /^I view the policy titled "([^"]*)"$/ do |title|
  click_link title
end

Then /^I should see that "([^"]*)" is the policy author$/ do |name|
  assert page.has_css?(".policy .author", text: name)
end

Then /^I should see that "([^"]*)" is the policy body$/ do |policy_body|
  assert page.has_css?(".policy .body", text: policy_body)
end

When /^I publish the policy called "([^"]*)"$/ do |title|
  When %{I open the policy "#{title}"}
  And %{I press publish}
end

Then /^I should be alerted that I am not the second set of eyes$/ do
  Then %{I should be alerted "You are not the second set of eyes"}
end

Then /^I should be alerted that I do not have privileges to publish policies$/ do
  Then %{I should be alerted "Only departmental editors can publish policies"}
end

Then /^I should see the policy "([^"]*)" in the list of submitted policies$/ do |title|
  assert page.has_css?('#submitted_policies .policy', text: title)
end

Given /^I open the policy "([^"]*)"$/ do |title|
  When %{I visit the list of policies awaiting review}
  click_link title
end

When /^another user changes the title from "([^"]*)" to "([^"]*)"$/ do |old_title, new_title|
  policy = Edition.find_by_title(old_title)
  policy.update_attributes(:title => new_title)
end

When /^I press publish$/ do
  click_button "Publish"
end