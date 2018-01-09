Given(/^a policy group "([^"]*)" exists$/) do |group_name|
  create(:policy_group, name: group_name)
end

When(/^I delete the policy group "([^"]*)"$/) do |group_name|
  visit admin_policy_groups_path
  group = PolicyGroup.where(name: group_name).first
  within(record_css_selector(group)) do
    click_button "Delete"
  end
end

Then(/^I should not see the policy group "([^"]*)"$/) do |group_name|
  within(".policy_groups") do
    assert page.has_no_content?(group_name)
  end
end

Then(/^I should be able to add attachments to the policy group "(.*?)"$/) do |group_name|
  group = PolicyGroup.find_by(name: group_name)
  attachment = upload_pdf_to_policy_group(group)
  insert_attachment_markdown_into_policy_group_description(attachment, group)
end
