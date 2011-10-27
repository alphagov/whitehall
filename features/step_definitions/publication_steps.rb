Given /^"([^"]*)" has received an email requesting they fact check a draft publication "([^"]*)"$/ do |email, title|
  publication = create(:draft_publication, title: title)
  fact_check_request = publication.fact_check_requests.create(email_address: email)
  Notifications.fact_check(fact_check_request, create(:user), host: "example.com").deliver
end

Given /^a submitted publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(file: File.open(pdf_attachment))
  create(:submitted_publication, title: title, attachment: attachment)
end

Given /^a published publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(file: File.open(pdf_attachment))
  create(:published_publication, title: title, attachment: attachment)
end

Given /^a published publication "([^"]*)" that's the responsibility of "([^"]*)" and "([^"]*)"$/ do |title, role_1_name, role_2_name|
  ministerial_role_1 = create(:ministerial_role, name: role_1_name)
  ministerial_role_2 = create(:ministerial_role, name: role_2_name)
  create(:published_publication, title: title, ministerial_roles: [ministerial_role_1, ministerial_role_2])
end

When /^I draft a new publication "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "Publication", title: title
  select first_policy, from: "Related Policies"
  select second_policy, from: "Related Policies"
  click_button "Save"
end

Then /^they should see the draft publication "([^"]*)"$/ do |title|
  publication = Publication.draft.find_by_title(title)
  assert page.has_css?('.document_view .title', text: publication.title)
  assert page.has_css?('.document_view .body', text: publication.body)
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment a[href*='attachment.pdf']", text: /^attachment\.pdf$/)
end

Then /^I can visit the published publication "([^"]*)" from the "([^"]*)" policy$/ do |publication_title, policy_title|
  policy = Policy.find_by_title(policy_title)
  visit public_document_path(policy)
  assert has_css?("#related-publications .publication a", text: publication_title)
  click_link publication_title
  assert has_css?(".title", text: publication_title)
end

Then /^I can visit the published consultation "([^"]*)" from the "([^"]*)" policy$/ do |consultation_title, policy_title|
  policy = Policy.find_by_title(policy_title)
  visit public_document_path(policy)
  assert has_css?("#related-consultations .consultation a", text: consultation_title)
  click_link consultation_title
  assert has_css?(".title", text: consultation_title)
end

def pdf_attachment
  Rails.root.join("features/fixtures/attachment.pdf")
end

