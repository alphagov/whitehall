Given /^a draft (publication|policy|news article|consultation|speech) "([^"]*)" exists$/ do |document_type, title|
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title: title)
end

Given /^a draft (publication|policy|news article|consultation) "([^"]*)" exists in the "([^"]*)" topic$/ do |document_type, title, topic_name|
  topic = Topic.find_by_name(topic_name)
  create("draft_#{document_class(document_type).name.underscore}".to_sym, title: title, topics: [topic])
end

Given /^a submitted (publication|policy|news article|consultation|speech) "([^"]*)" exists$/ do |document_type, title|
  create("submitted_#{document_class(document_type).name.underscore}".to_sym, title: title)
end

Given /^another user edits the (publication|policy|news article|consultation|speech) "([^"]*)" changing the title to "([^"]*)"$/ do |document_type, original_title, new_title|
  document = document_class(document_type).find_by_title(original_title)
  document.update_attributes!(title: new_title)
end

Given /^a published (publication|policy|news article|consultation|speech) "([^"]*)" that's the responsibility of:$/ do |document_type, title, table|
  document = create(:"published_#{document_type}", title: title)
  table.hashes.each do |row|
    person = Person.find_or_create_by_name(row["Person"])
    ministerial_role = MinisterialRole.find_or_create_by_name(row["Ministerial Role"])
    person.ministerial_roles << ministerial_role
    document.ministerial_roles << ministerial_role
  end
end

When /^I view the (publication|policy|news article|consultation|speech) "([^"]*)"$/ do |document_type, title|
  click_link title
end

When /^I visit the list of documents awaiting review$/ do
  visit submitted_admin_documents_path
end

When /^I visit the (publication|policy|news article|consultation) "([^"]*)"$/ do |document_type, title|
  document = document_class(document_type).find_by_title(title)
  visit public_document_path(document)
end

When /^I draft a new (publication|policy|news article) "([^"]*)"$/ do |document_type, title|
  begin_drafting_document type: document_type, title: title
  click_button "Save"
end

When /^I draft a new consultation "([^"]*)"$/ do |title|
  begin_drafting_document type: 'consultation', title: title
  select_date "Opening Date", with: 1.day.ago.to_s
  select_date "Closing Date", with: 6.days.from_now.to_s
  click_button "Save"
end

When /^I submit the (publication|policy|news article|consultation|speech) "([^"]*)"$/ do |document_type, title|
  document = document_class(document_type).find_by_title(title)
  visit_document_preview title
  click_button "Submit to 2nd pair of eyes"
end

When /^I publish the (publication|policy|news article|consultation|speech) "([^"]*)"$/ do |document_type, title|
  document = document_class(document_type).find_by_title(title)
  visit_document_preview title
  click_button "Publish"
end

When /^I save my changes to the (publication|policy|news article|consultation|speech)$/ do |document_type|
  click_button "Save"
end

When /^I edit the (publication|policy|news article|consultation) changing the title to "([^"]*)"$/ do |document_type, new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

Then /^I should see the (publication|policy|news article|consultation|speech) "([^"]*)" in the list of draft documents$/ do |document_type, title|
  document = document_class(document_type).find_by_title(title)
  visit admin_documents_path
  assert has_css?(record_css_selector(document))
end

Then /^I should see the (publication|policy|news article|consultation|speech) "([^"]*)" in the list of submitted documents$/ do |document_type, title|
  document = document_class(document_type).find_by_title(title)
  visit submitted_admin_documents_path
  assert has_css?(record_css_selector(document))
end

Then /^I should see the (publication|policy|news article|consultation|speech) "([^"]*)" in the list of published documents$/ do |document_type, title|
  document = document_class(document_type).find_by_title(title)
  visit published_admin_documents_path
  assert has_css?(record_css_selector(document))
end

Then /^the (publication|policy|news article|consultation|speech) "([^"]*)" should be visible to the public$/ do |document_type, title|
  document = document_class(document_type).find_by_title(title)
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

Then /^I should see in the preview that "([^"]*)" should related to "([^"]*)" and "([^"]*)" policies$/ do |title, related_policy_1, related_policy_2|
  visit_document_preview title
  assert has_css?("#related-documents .policy", text: related_policy_1)
  assert has_css?("#related-documents .policy", text: related_policy_2)
end

Then /^I should see the conflict between the (publication|policy|news article|consultation|speech) titles "([^"]*)" and "([^"]*)"$/ do |document_type, new_title, latest_title|
  assert page.has_css?(".conflicting.new #document_title", value: new_title)
  assert page.has_css?(".conflicting.latest .document .title", value: latest_title)
end

Then /^my attempt to publish "([^"]*)" should fail$/ do |title|
  document = Document.find_by_title(title)
  assert !document.published?
end
