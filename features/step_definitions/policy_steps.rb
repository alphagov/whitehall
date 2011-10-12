Given /^I am on the policies admin page$/ do
  visit admin_documents_path
end

Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am logged in as a writer called "#{author}"}
  And %{I visit the new policy page}
  And %{I write and save a policy called "#{title}" with body "#{body}"}
  And %{I submit the policy for the second set of eyes}
end

Given /^a published policy titled "([^"]*)" that appears in the "([^"]*)" and "([^"]*)" topics$/ do |policy_title, topic_1, topic_2|
  document = create(:published_policy, title: policy_title)
  create(:topic, name: topic_1, documents: [document])
  create(:topic, name: topic_2, documents: [document])
end

Given /^I visit the list of published policies$/ do
  visit published_admin_documents_path
end

Given /^"([^"]*)" has received an email requesting they fact check a draft policy titled "([^"]*)"$/ do |email, title|
  document = create(:draft_policy, title: title)
  fact_check_request = document.fact_check_requests.create(email_address: email)
  Notifications.fact_check(fact_check_request, host: "example.com").deliver
end

Given /^a submitted policy titled "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(name: File.open(pdf_attachment))
  create(:submitted_policy, title: title, attachment: attachment)
end

Given /^a published policy titled "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(name: File.open(pdf_attachment))
  create(:published_policy, title: title, attachment: attachment)
end

Given /^a published policy titled "([^"]*)" that's the responsibility of "([^"]*)" and "([^"]*)"$/ do |title, role_1_name, role_2_name|
  ministerial_role_1 = create(:ministerial_role, name: role_1_name)
  ministerial_role_2 = create(:ministerial_role, name: role_2_name)
  create(:published_policy, title: title, ministerial_roles: [ministerial_role_1, ministerial_role_2])
end

When /^I create a new edition of the published policy$/ do
  Given %{I visit the list of published policies}
  click_link Document.published.last.title
  click_button 'Create new draft'
end

When /^I edit the new edition$/ do
  fill_in 'Title', with: "New title"
  fill_in 'Policy', with: "New policy"
  click_button 'Save'
end

When /^"([^"]*)" clicks the email link to the draft policy$/ do |email|
  When %{I open the last email sent to "#{email}"}
  And %{I click the first link in the email}
end

When /^I visit the policy titled "([^"]*)"$/ do |title|
  document = Document.find_by_title(title)
  visit document_path(document.document_identity)
end

Then /^I should see links to the "([^"]*)" and "([^"]*)" topics$/ do |topic_1_name, topic_2_name|
  topic_1 = Topic.find_by_name(topic_1_name)
  topic_2 = Topic.find_by_name(topic_2_name)
  assert page.has_css?("#topics a[href='#{topic_path(topic_1)}']", text: topic_1_name)
  assert page.has_css?("#topics a[href='#{topic_path(topic_2)}']", text: topic_2_name)
end

Then /^the published policy should remain unchanged$/ do
  visit document_path(@document.document_identity)
  assert page.has_css?('.document_view .title', text: @document.title)
  assert page.has_css?('.document_view .body', text: @document.body)
end

Then /^they should see the draft policy titled "([^"]*)"$/ do |title|
  document = Document.find_by_title(title)
  assert page.has_css?('.document_view .title', text: document.title)
  assert page.has_css?('.document_view .body', text: document.body)
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment a[href*='attachment.pdf']", text: /^attachment\.pdf$/)
end

Given /^a published (policy|publication) titled "([^"]*)" that's the responsibility of:$/ do |document_type, title, table|
  document = create(:"published_#{document_type}", title: title)
  table.hashes.each do |row|
    person = Person.find_or_create_by_name(row["Person"])
    role = person.ministerial_roles.find_or_create_by_name(row["Ministerial Role"])
    document.ministerial_roles << role
  end
end

Then /^I should see that those responsible for the policy are:$/ do |table|
  table.hashes.each do |row|
    person = Person.find_by_name(row["Person"])
    ministerial_role = person.ministerial_roles.find_by_name(row["Ministerial Role"])
    assert page.has_css?(".ministerial_role", text: ministerial_role.to_s)
  end
end

def pdf_attachment
  Rails.root.join("features/fixtures/attachment.pdf")
end