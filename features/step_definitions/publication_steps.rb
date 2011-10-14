Given /^"([^"]*)" has received an email requesting they fact check a draft publication "([^"]*)"$/ do |email, title|
  document = create(:draft_policy, title: title)
  fact_check_request = document.fact_check_requests.create(email_address: email)
  Notifications.fact_check(fact_check_request, create(:user), host: "example.com").deliver
end

Given /^a submitted publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(name: File.open(pdf_attachment))
  create(:submitted_policy, title: title, attachment: attachment)
end

Given /^a published publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(name: File.open(pdf_attachment))
  create(:published_policy, title: title, attachment: attachment)
end

Given /^a published publication "([^"]*)" that's the responsibility of "([^"]*)" and "([^"]*)"$/ do |title, role_1_name, role_2_name|
  ministerial_role_1 = create(:ministerial_role, name: role_1_name)
  ministerial_role_2 = create(:ministerial_role, name: role_2_name)
  create(:published_policy, title: title, ministerial_roles: [ministerial_role_1, ministerial_role_2])
end

When /^I view the publication "([^"]*)"$/ do |title|
  click_link title
end

Then /^they should see the draft publication "([^"]*)"$/ do |title|
  document = Document.find_by_title(title)
  assert page.has_css?('.document_view .title', text: document.title)
  assert page.has_css?('.document_view .body', text: document.body)
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment a[href*='attachment.pdf']", text: /^attachment\.pdf$/)
end

def pdf_attachment
  Rails.root.join("features/fixtures/attachment.pdf")
end