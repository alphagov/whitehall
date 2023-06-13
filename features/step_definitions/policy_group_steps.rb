Given(/^a policy group "([^"]*)" exists$/) do |group_name|
  create(:policy_group, name: group_name)
end

When(/^I delete the policy group "([^"]*)"$/) do |group_name|
  visit admin_policy_groups_path

  click_link "Delete #{group_name}"
  click_button "Delete"
end

Then(/^I should not see the policy group "([^"]*)"$/) do |group_name|
  within(".govuk-table") do
    expect(page).to_not have_content(group_name)
  end
end

Then(/^I should be able to add attachments to the policy group "(.*?)"$/) do |group_name|
  group = PolicyGroup.find_by(name: group_name)
  attachment = upload_pdf_to_policy_group(group)
  insert_attachment_markdown_into_policy_group_description(attachment, group)
end
