Given /^a draft (publication|policy) called "([^"]*)" exists$/ do |document_type, title|
  create("draft_#{document_type}".to_sym, title: title)
end

Given /^a draft (publication|policy) called "([^"]*)" exists in the "([^"]*)" topic$/ do |document_type, title, topic_name|
  topic = Topic.find_by_name(topic_name)
  create("draft_#{document_type}".to_sym, title: title, topics: [topic])
end

Given /^a submitted (publication|policy) called "([^"]*)" exists$/ do |document_type, title|
  create("submitted_#{document_type}".to_sym, title: title)
end

Given /^I start editing the policy "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  begin_editing_document original_title
  fill_in "Title", with: new_title
end

Given /^another user edits the (publication|policy) "([^"]*)" changing the title to "([^"]*)"$/ do |document_type, original_title, new_title|
  document = Document.find_by_title(original_title)
  document.update_attributes!(title: new_title)
end

When /^I draft a new (publication|policy) "([^"]*)"$/ do |document_type, title|
  begin_drafting_document type: document_type, title: title
  click_button "Save"
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

When /^I submit the (publication|policy) "([^"]*)"$/ do |document_type, title|
  document = Document.find_by_title(title)
  assert document.is_a?(document_type.classify.constantize)
  visit_document_preview title
  click_button "Submit to 2nd pair of eyes"
end

When /^I publish the (publication|policy) "([^"]*)"$/ do |document_type, title|
  document = Document.find_by_title(title)
  assert document.is_a?(document_type.classify.constantize)
  visit_document_preview title
  click_button "Publish"
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

When /^I save my changes to the (publication|policy)$/ do |document_type|
  click_button "Save"
end

When /^I edit the (publication|policy) changing the title to "([^"]*)"$/ do |document_type, new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I publish the policy "([^"]*)" but another user edits it while I am viewing it$/ do |title|
  document = Document.find_by_title(title)
  visit_document_preview title
  document.update_attributes!(body: 'A new body')
  click_button "Publish"
end

When /^I add a supporting document "([^"]*)" to the "([^"]*)" policy$/ do |supporting_title, policy_title|
  policy = Policy.find_by_title(policy_title)
  visit admin_document_path(policy)
  click_link "Add supporting document"
  fill_in "Title", with: supporting_title
  fill_in "Body", with: "Some supporting information"
  click_button "Save"
end

Then /^I should see the (publication|policy) "([^"]*)" in the list of draft documents$/ do |document_type, title|
  document = Document.find_by_title(title)
  visit admin_documents_path
  within record_css_selector(document) do
    assert has_css?(".type", text: document_type.classify)
  end
end

Then /^I should see the (publication|policy) "([^"]*)" in the list of submitted documents$/ do |document_type, title|
  document = Document.find_by_title(title)
  visit submitted_admin_documents_path
  within record_css_selector(document) do
    assert has_css?(".type", text: document_type.classify)
  end
end

Then /^I should see the (publication|policy) "([^"]*)" in the list of published documents$/ do |document_type, title|
  document = Document.find_by_title(title)
  visit published_admin_documents_path
  within record_css_selector(document) do
    assert has_css?(".type", text: document_type.classify)
  end
end

Then /^the (publication|policy) "([^"]*)" should be visible to the public$/ do |document_type, title|
  document = Document.find_by_title(title)
  assert document.is_a?(document_type.classify.constantize)
  visit documents_path
  assert page.has_css?(record_css_selector(document), text: title)
end

Then /^I should see in the preview that "([^"]*)" should be in the "([^"]*)" and "([^"]*)" topics$/ do |title, first_topic, second_topic|
  visit_document_preview title
  assert has_css?(".topic", text: first_topic)
  assert has_css?(".topic", text: second_topic)
end

Then /^I should see in the preview that "([^"]*)" should be in the "([^"]*)" and "([^"]*)" organisations$/ do |title, first_org, second_org|
  visit_document_preview title
  assert has_css?(".organisation", text: first_org)
  assert has_css?(".organisation", text: second_org)
end

Then /^I should see in the preview that "([^"]*)" is associated with "([^"]*)" and "([^"]*)"$/ do |title, minister_1, minister_2|
  visit_document_preview title
  assert has_css?(".ministerial_role", text: minister_1)
  assert has_css?(".ministerial_role", text: minister_2)
end

Then /^I should see the conflict between the (publication|policy) titles "([^"]*)" and "([^"]*)"$/ do |document_type, new_title, latest_title|
  assert page.has_css?(".conflicting.new #document_title", value: new_title)
  assert page.has_css?(".conflicting.latest #document_title[disabled]", value: latest_title)
end

Then /^my attempt to publish "([^"]*)" should fail$/ do |title|
  document = Document.find_by_title(title)
  assert !document.published?
end

Then /^I should see the supporting document "([^"]*)" on the "([^"]*)" policy$/ do |supporting_title, policy_title|
  policy = Policy.find_by_title(policy_title)
  visit admin_document_path(policy)
  assert has_css?(".supporting_document", text: supporting_title)
end
