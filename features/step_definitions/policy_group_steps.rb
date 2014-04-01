Given /^a policy group "([^"]*)" exists$/ do |group_name|
  create(:policy_group, name: group_name)
end

When /^I associate the policy group "([^"]*)" with the policy "([^"]*)"$/ do |group_name, policy_title|
  begin_editing_document policy_title
  select group_name, from: "Groups"
  click_button "Save"
end

When /^I associate the policy groups "([^"]*)" and "([^"]+)" with the policy "([^"]*)"$/ do |group_name, group_2, policy_title|
  begin_editing_document policy_title
  select group_name, from: "Groups"
  select group_2, from: "Groups"
  click_button "Save"
end

Then /^I should see the policy group "([^"]*)"$/ do |group_name|
  assert page.has_text?(group_name)
end

Then /^I should see a link to the policy group "([^"]*)"$/ do |group_name|
  assert page.has_css?('a', text: group_name)
end

When /^I visit the policy group "([^"]*)"$/ do |group_name|
  group = Policy.where(name: group_name).first
  visit policy_group_path(group)
end

When /^I delete the policy group "([^"]*)"$/ do |group_name|
  visit admin_policy_groups_path
  group = PolicyGroup.where(name: group_name).first
  within(record_css_selector(group)) do
    click_button "Delete"
  end
end

Then /^I should not see the policy group "([^"]*)"$/ do |group_name|
  within(".policy_groups") do
    assert page.has_no_content?(group_name)
  end
end

Then /^I should be able to add attachments to the policy group "(.*?)"$/ do |group_name|
  group = PolicyGroup.find_by_name(group_name)
  attachment = upload_pdf_to_policy_group(group)
  insert_attachment_markdown_into_policy_group_description(attachment, group)
  check_attachment_appears_on_policy_group(attachment, group)
end
