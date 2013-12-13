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

Then /^I should be able to add attachments to the policy advisory group "(.*?)"$/ do |group_name|
  group = PolicyAdvisoryGroup.find_by_name(group_name)
  attachment = upload_pdf_to_policy_advisory_group(group)
  insert_attachment_markdown_into_policy_advisory_group_description(attachment, group)
  check_attachment_appears_on_policy_advisory_group(attachment, group)
end
