Given /^I am on the policies admin page$/ do
  visit admin_documents_path
end

Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am a writer called "#{author}"}
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

Given /^a published policy exists$/ do
  @document = create(:published_policy)
end

Given /^I start editing the policy "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
end

When /^I create a new edition of the published policy$/ do
  visit published_admin_documents_path
  click_link Policy.published.last.title
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
  document = Policy.find_by_title(title)
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

When /^I draft a new policy "([^"]*)" in the "([^"]*)" and "([^"]*)" topics$/ do |title, first_topic, second_topic|
  begin_drafting_document type: "Policy", title: title
  select first_topic, from: "Topics"
  select second_topic, from: "Topics"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" in the "([^"]*)" and "([^"]*)" organisations$/ do |title, first_org, second_org|
  begin_drafting_document type: "Policy", title: title
  select first_org, from: "Organisations"
  select second_org, from: "Organisations"
  click_button "Save"
end

When /^I draft a new policy "([^"]*)" associated with "([^"]*)" and "([^"]*)"$/ do |title, minister_1, minister_2|
  begin_drafting_document type: "Policy", title: title
  select minister_1, from: "Ministers"
  select minister_2, from: "Ministers"
  click_button "Save"
end

When /^I edit the policy "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I edit the policy "([^"]*)" adding it to the "([^"]*)" topic$/ do |title, topic_name|
  begin_editing_document title
  select topic_name, from: "Topics"
  click_button "Save"
end

When /^I publish the policy "([^"]*)" but another user edits it while I am viewing it$/ do |title|
  document = Policy.find_by_title(title)
  visit_document_preview title
  document.update_attributes!(body: 'A new body')
  click_button "Publish"
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