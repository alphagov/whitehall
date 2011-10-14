Given /^I am on the policies admin page$/ do
  visit admin_documents_path
end

Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am logged in as a writer called "#{author}"}
  And %{I visit the new policy page}
  And %{I write and save a policy "#{title}" with body "#{body}"}
  And %{I submit the policy for the second set of eyes}
end

Given /^a published policy "([^"]*)" that appears in the "([^"]*)" and "([^"]*)" topics$/ do |policy_title, topic_1, topic_2|
  document = create(:published_policy, title: policy_title)
  create(:topic, name: topic_1, documents: [document])
  create(:topic, name: topic_2, documents: [document])
end

Given /^I visit the list of draft policies$/ do
  visit admin_documents_path
end

Given /^I click edit for the policy "([^"]*)"$/ do |policy_title|
  click_link policy_title
  click_link "Edit"
end

Given /^I submit the policy for the second set of eyes$/ do
  click_button 'Submit to 2nd pair of eyes'
end

When /^I visit the list of policies awaiting review$/ do
  visit submitted_admin_documents_path
end

When /^I create a new edition of the published policy$/ do
  visit published_admin_documents_path
  click_link Document.published.last.title
  click_button 'Create new draft'
end

When /^I edit the new edition$/ do
  fill_in 'Title', with: "New title"
  fill_in 'Policy', with: "New policy"
  click_button 'Save'
end

When /^I visit the new policy page$/ do
  visit new_admin_document_path
end

When /^I request that "([^"]*)" fact checks the policy "([^"]*)"$/ do |email, title|
  document = Document.find_by_title(title)
  assert document.is_a?(Policy)
  visit admin_documents_path
  within(record_css_selector(document)) do
    click_link title
  end
  click_link 'Edit'
  within("#new_fact_check_request") do
    fill_in "Email address", with: email
    click_button "Send request"
  end
end

When /^I write and save a policy "([^"]*)" with body "([^"]*)"$/ do |title, body|
  When %{I write a policy "#{title}" with body "#{body}"}
  click_button 'Save'
end

When /^I write a policy "([^"]*)" with body "([^"]*)"$/ do |title, body|
  fill_in 'Title', with: title
  fill_in 'Policy', with: body
end

Then /^I should see the fact checking feedback "([^"]*)"$/ do |comments|
  assert page.has_css?(".fact_check_request .comments", text: comments)
end

Then /^the published policy should remain unchanged$/ do
  visit document_path(@document.document_identity)
  assert page.has_css?('.document_view .title', text: @document.title)
  assert page.has_css?('.document_view .body', text: @document.body)
end

Then /^I should see that those responsible for the policy are:$/ do |table|
  table.hashes.each do |row|
    person = Person.find_by_name(row["Person"])
    ministerial_role = person.ministerial_roles.find_by_name(row["Ministerial Role"])
    assert page.has_css?(".ministerial_role", text: ministerial_role.to_s)
  end
end

Then /^I should see that "([^"]*)" is the policy author$/ do |name|
  assert page.has_css?(".document_view .author", text: name)
end

Then /^I should see that "([^"]*)" is the policy body$/ do |policy_body|
  assert page.has_css?(".document_view .body", text: policy_body)
end