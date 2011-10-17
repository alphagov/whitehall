Given /^a draft (publication|policy) "([^"]*)" exists$/ do |document_type, title|
  create("draft_#{document_type}".to_sym, title: title)
end

Given /^a draft (publication|policy) "([^"]*)" exists in the "([^"]*)" topic$/ do |document_type, title, topic_name|
  topic = Topic.find_by_name(topic_name)
  create("draft_#{document_type}".to_sym, title: title, topics: [topic])
end

Given /^a submitted (publication|policy) "([^"]*)" exists$/ do |document_type, title|
  create("submitted_#{document_type}".to_sym, title: title)
end

Given /^another user edits the (publication|policy) "([^"]*)" changing the title to "([^"]*)"$/ do |document_type, original_title, new_title|
  document = document_type.classify.constantize.find_by_title(original_title)
  document.update_attributes!(title: new_title)
end

Given /^a published (policy|publication) "([^"]*)" that's the responsibility of:$/ do |document_type, title, table|
  document = create(:"published_#{document_type}", title: title)
  table.hashes.each do |row|
    person = Person.find_or_create_by_name(row["Person"])
    role = person.ministerial_roles.find_or_create_by_name(row["Ministerial Role"])
    document.ministerial_roles << role
  end
end

When /^I view the (policy|publication) "([^"]*)"$/ do |document_type, title|
  click_link title
end

When /^I visit the list of documents awaiting review$/ do
  visit submitted_admin_documents_path
end

When /^I visit the (policy|publication) "([^"]*)"$/ do |document_type, title|
  document = document_type.classify.constantize.find_by_title(title)
  visit document_path(document.document_identity)
end

When /^I draft a new (publication|policy) "([^"]*)"$/ do |document_type, title|
  begin_drafting_document type: document_type, title: title
  click_button "Save"
end

When /^I submit the (publication|policy) "([^"]*)"$/ do |document_type, title|
  document = document_type.classify.constantize.find_by_title(title)
  visit_document_preview title
  click_button "Submit to 2nd pair of eyes"
end

When /^I publish the (publication|policy) "([^"]*)"$/ do |document_type, title|
  document = document_type.classify.constantize.find_by_title(title)
  visit_document_preview title
  click_button "Publish"
end

When /^I save my changes to the (publication|policy)$/ do |document_type|
  click_button "Save"
end

When /^I edit the (publication|policy) changing the title to "([^"]*)"$/ do |document_type, new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

Then /^I should see the (publication|policy) "([^"]*)" in the list of draft documents$/ do |document_type, title|
  document = document_type.classify.constantize.find_by_title(title)
  visit admin_documents_path
  within record_css_selector(document) do
    assert has_css?(".type", text: document_type.classify)
  end
end

Then /^I should see the (publication|policy) "([^"]*)" in the list of submitted documents$/ do |document_type, title|
  document = document_type.classify.constantize.find_by_title(title)
  visit submitted_admin_documents_path
  within record_css_selector(document) do
    assert has_css?(".type", text: document_type.classify)
  end
end

Then /^I should see the (publication|policy) "([^"]*)" in the list of published documents$/ do |document_type, title|
  document = document_type.classify.constantize.find_by_title(title)
  visit published_admin_documents_path
  within record_css_selector(document) do
    assert has_css?(".type", text: document_type.classify)
  end
end

Then /^the (publication|policy) "([^"]*)" should be visible to the public$/ do |document_type, title|
  document = document_type.classify.constantize.find_by_title(title)
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

Then /^I should see in the preview that "([^"]*)" only applies to the nations:$/ do |title, nation_names|
  visit_document_preview title
  nation_names.raw.flatten.each do |nation_name|
    assert has_css?(".nation", nation_name)
  end
end

Then /^I should see the conflict between the (publication|policy) titles "([^"]*)" and "([^"]*)"$/ do |document_type, new_title, latest_title|
  assert page.has_css?(".conflicting.new #document_title", value: new_title)
  assert page.has_css?(".conflicting.latest .document .title", value: latest_title)
end

Then /^my attempt to publish "([^"]*)" should fail$/ do |title|
  document = Document.find_by_title(title)
  assert !document.published?
end
