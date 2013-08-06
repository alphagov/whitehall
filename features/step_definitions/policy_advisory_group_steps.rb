Given /^a policy advisory group "([^"]*)" exists$/ do |group_name|
  create(:policy_advisory_group, name: group_name)
end

When /^I associate the policy advisory group "([^"]*)" with the policy "([^"]*)"$/ do |group_name, policy_title|
  begin_editing_document policy_title
  select group_name, from: "Policy Advisory Groups"
  click_button "Save"
end

When /^I associate the policy advisory groups "([^"]*)" and "([^"]+)" with the policy "([^"]*)"$/ do |group_name, group_2, policy_title|
  begin_editing_document policy_title
  select group_name, from: "Policy Advisory Groups"
  select group_2, from: "Policy Advisory Groups"
  click_button "Save"
end

Then /^I should see the policy advisory group "([^"]*)"$/ do |group_name|
  assert page.has_text?(group_name)
end

Then /^I should see a link to the policy advisory group "([^"]*)"$/ do |group_name|
  assert page.has_css?('a', text: group_name)
end

Then /^I should see the policy advisory group "([^"]*)" hidden behind a "([^"]*)" link$/ do |group_name, button_text|
  group = PolicyAdvisoryGroup.where(name: group_name).first
  assert page.has_css?(".visuallyhidden #{record_css_selector(group)}")
  assert page.has_css?(".toggle.show-other-content", text: button_text)
end

When /^I visit the policy advisory group "([^"]*)"$/ do |group_name|
  group = PolicyAdvisoryGroup.where(name: group_name).first
  visit policy_advisory_group_path(group)
end

When /^I delete the policy advisory group "([^"]*)"$/ do |group_name|
  visit admin_policy_advisory_groups_path
  group = PolicyAdvisoryGroup.where(name: group_name).first
  within(record_css_selector(group)) do
    click_button "Delete"
  end
end

Then /^I should not see the policy advisory group "([^"]*)"$/ do |group_name|
  within(".policy_advisory_groups") do
    assert page.has_no_content?(group_name)
  end
end

Given /^I attach a PDF document "([^"]*)" to the policy advisory group "([^"]*)"$/ do |attachment_name, group_name|
  group = PolicyAdvisoryGroup.where(name: group_name).first
  visit edit_admin_policy_advisory_group_path(group)
  add_attachment(attachment_name, "attachment.pdf", "#policy_group_attachment_fields")
  click_button "Save"
end

When /^I insert the attachment into the body of policy advisory group "([^"]*)"$/ do |group_name|
  group = PolicyAdvisoryGroup.where(name: group_name).first
  group.description += "\n\n!@1"
  group.save
end

Then /^I should be able to see a PDF document "([^"]*)"$/ do |attachment_name|
  assert page.has_css?('.attachment-details .title', text: attachment_name)
end
