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

Given /^I start editing the (publication|policy) "([^"]*)" changing the title to "([^"]*)"$/ do |document_type, original_title, new_title|
  document = Document.find_by_title(original_title)
  visit admin_document_path(document)
  click_link "Edit"
  fill_in "Title", with: new_title
end

Given /^another user edits the (publication|policy) "([^"]*)" changing the title to "([^"]*)"$/ do |document_type, original_title, new_title|
  document = Document.find_by_title(original_title)
  document.update_attributes!(title: new_title)
end

When /^I draft a new (publication|policy) "([^"]*)"$/ do |document_type, title|
  visit admin_documents_path
  click_link "Draft new #{document_type.capitalize}"
  fill_in "Title", with: title
  fill_in "Policy", with: "Any old iron"
  click_button "Save"
end

When /^I draft a new (publication|policy) "([^"]*)" in the "([^"]*)" and "([^"]*)" topics$/ do |document_type, title, first_topic, second_topic|
  visit admin_documents_path
  click_link "Draft new #{document_type.capitalize}"
  fill_in "Title", with: title
  fill_in "Policy", with: "Any old iron"
  select first_topic, from: "Topics"
  select second_topic, from: "Topics"
  click_button "Save"
end

When /^I draft a new (publication|policy) "([^"]*)" in the "([^"]*)" and "([^"]*)" organisations$/ do |document_type, title, first_org, second_org|
  visit admin_documents_path
  click_link "Draft new #{document_type.capitalize}"
  fill_in "Title", with: title
  fill_in "Policy", with: "Any old iron"
  select first_org, from: "Organisations"
  select second_org, from: "Organisations"
  click_button "Save"
end

When /^I submit the (publication|policy) "([^"]*)"$/ do |document_type, title|
  document = Document.find_by_title(title)
  assert document.is_a?(document_type.classify.constantize)
  visit admin_document_path(document)
  click_button "Submit to 2nd pair of eyes"
end

When /^I publish the (publication|policy) "([^"]*)"$/ do |document_type, title|
  document = Document.find_by_title(title)
  assert document.is_a?(document_type.classify.constantize)
  visit admin_document_path(document)
  click_button "Publish"
end

When /^I edit the (publication|policy) "([^"]*)" changing the title to "([^"]*)"$/ do |document_type, original_title, new_title|
  document = Document.find_by_title(original_title)
  visit admin_document_path(document)
  click_link "Edit"
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I edit the (publication|policy) "([^"]*)" adding it to the "([^"]*)" topic$/ do |document_type, title, topic_name|
  document = Document.find_by_title(title)
  visit admin_document_path(document)
  click_link "Edit"
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

When /^I publish the (publication|policy) "([^"]*)" but another user edits it while I am viewing it$/ do |document_type, title|
  document = Document.find_by_title(title)
  assert document.is_a?(document_type.classify.constantize)
  visit admin_document_path(document)
  document.update_attributes!(body: 'A new body')
  click_button "Publish"
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

Then /^the (publication|policy) "([^"]*)" should be in the "([^"]*)" and "([^"]*)" topics$/ do |document_type, title, first_topic, second_topic|
  document = Document.find_by_title(title)
  assert document.is_a?(document_type.classify.constantize)
  visit admin_document_path(document)
  assert has_css?(".topic", text: first_topic)
  assert has_css?(".topic", text: second_topic)
end

Then /^the (publication|policy) "([^"]*)" should be in the "([^"]*)" and "([^"]*)" organisations$/ do |document_type, title, first_org, second_org|
  document = Document.find_by_title(title)
  assert document.is_a?(document_type.classify.constantize)
  visit admin_document_path(document)
  assert has_css?(".organisation", text: first_org)
  assert has_css?(".organisation", text: second_org)
end

Then /^I should see the conflict between the (publication|policy) titles "([^"]*)" and "([^"]*)"$/ do |document_type, new_title, latest_title|
  assert page.has_css?(".conflicting.new #document_title", value: new_title)
  assert page.has_css?(".conflicting.latest #document_title[disabled]", value: latest_title)
end

Then /^my attempt to publish "([^"]*)" should fail$/ do |title|
  document = Document.find_by_title(title)
  assert !document.published?
end
