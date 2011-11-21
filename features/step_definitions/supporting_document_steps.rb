Given /^a supporting document "([^"]*)" exists on a draft policy "([^"]*)"$/ do |supporting_title, document_title|
  document = create(:draft_policy, title: document_title)
  create(:supporting_document, document: document, title: supporting_title)
end

Given /^a published policy "([^"]*)" with supporting documents "([^"]*)" and "([^"]*)"$/ do |policy_title, first_supporting_title, second_supporting_title|
  document = create(:published_policy, title: policy_title)
  create(:supporting_document, document: document, title: first_supporting_title)
  create(:supporting_document, document: document, title: second_supporting_title)
end

Given /^a draft policy "([^"]*)" with supporting documents "([^"]*)" and "([^"]*)"$/ do |policy_title, first_supporting_title, second_supporting_title|
  document = create(:draft_policy, title: policy_title)
  create(:supporting_document, document: document, title: first_supporting_title)
  create(:supporting_document, document: document, title: second_supporting_title)
end

Given /^I start editing the supporting document "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  supporting_document = SupportingDocument.find_by_title!(original_title)
  visit admin_supporting_document_path(supporting_document)
  click_link "Edit"
  fill_in "Title", with: new_title
end

Given /^another user edits the supporting document "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  supporting_document = SupportingDocument.find_by_title!(original_title)
  supporting_document.update_attributes!(title: new_title)
end

When /^I save my changes to the supporting document$/ do
  click_button "Save"
end

When /^I edit the supporting document "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  supporting_document = SupportingDocument.find_by_title!(original_title)
  visit admin_document_path(supporting_document.document)
  click_link original_title
  click_link "Edit"
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I add a supporting document "([^"]*)" to the "([^"]*)" policy$/ do |supporting_title, policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_document_path(policy)
  click_link "Add supporting document"
  fill_in "Title", with: supporting_title
  fill_in "Body", with: "Some supporting information"
  click_button "Save"
end

When /^I edit the supporting document changing the title to "([^"]*)"$/ do |new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I remove the supporting document "([^"]*)" from "([^"]*)"$/ do |supporting_document_title, title|
  visit_document_preview title
  click_link supporting_document_title
  click_button "Remove"
end

Then /^I should see the conflict between the supporting document titles "([^"]*)" and "([^"]*)"$/ do |new_title, latest_title|
  assert page.has_css?(".conflicting.new #supporting_document_title", value: new_title)
  assert page.has_css?(".conflicting.latest #supporting_document_title[disabled]", value: latest_title)
end

Then /^I should see in the preview that "([^"]*)" includes the "([^"]*)" supporting document$/ do |title, supporting_title|
  visit_document_preview title
  assert has_css?(".supporting_document", text: supporting_title)
  click_link supporting_title
  assert has_css?(".title", text: supporting_title)
end

Then /^I can visit the supporting document "([^"]*)" from the "([^"]*)" policy$/ do |supporting_title, policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit public_document_path(policy)
  assert has_css?(".policy_view nav a", text: supporting_title)
  click_link supporting_title
  supporting_document = policy.supporting_documents.find_by_title!(supporting_title)
  assert has_css?(".document .body", text: supporting_document.body)
end

Then /^I should see in the list of draft documents that "([^"]*)" has supporting document "([^"]*)"$/ do |title, supporting_document_title|
  visit draft_admin_documents_path
  click_link "by everyone"
  document = Document.find_by_title!(title)
  within(record_css_selector(document)) do
    assert has_css?(".supporting_documents", text: /#{supporting_document_title}/)
  end
end

Then /^I should see in the preview that the only supporting document for "([^"]*)" is "([^"]*)"$/ do |title, supporting_document_title|
  visit_document_preview title
  assert has_css?(".supporting_documents .supporting_document", count: 1)
  assert has_css?(".supporting_documents", text: /#{supporting_document_title}/)
end