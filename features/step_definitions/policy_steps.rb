Given /^I am on the policies admin page$/ do
  visit admin_editions_path
end

Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am logged in as a writer called "#{author}"}
  And %{I visit the new policy page}
  And %{I write and save a policy called "#{title}" with body "#{body}"}
  And %{I submit the policy for the second set of eyes}
end

Given /^a published policy titled "([^"]*)" that appears in the "([^"]*)" and "([^"]*)" topics$/ do |policy_title, topic_1, topic_2|
  edition = create(:published_policy, title: policy_title)
  create(:topic, name: topic_1, editions: [edition])
  create(:topic, name: topic_2, editions: [edition])
end

Given /^I visit the list of published policies$/ do
  visit published_admin_editions_path
end

Given /^"([^"]*)" has received an email requesting they fact check a draft policy titled "([^"]*)"$/ do |email, title|
  edition = create(:draft_policy, title: title)
  fact_check_request = edition.fact_check_requests.create(email_address: email)
  Notifications.fact_check(fact_check_request).deliver
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
  role_1 = create(:role, name: role_1_name)
  role_2 = create(:role, name: role_2_name)
  create(:published_policy, title: title, roles: [role_1, role_2])
end

When /^I create a new edition of the published policy$/ do
  Given %{I visit the list of published policies}
  click_link Edition.published.last.title
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
  edition = Edition.find_by_title(title)
  visit document_path(edition.document_identity)
end

Then /^I should see links to the "([^"]*)" and "([^"]*)" topics$/ do |topic_1_name, topic_2_name|
  topic_1 = Topic.find_by_name(topic_1_name)
  topic_2 = Topic.find_by_name(topic_2_name)
  assert page.has_css?("#topics a[href='#{topic_path(topic_1)}']", text: topic_1_name)
  assert page.has_css?("#topics a[href='#{topic_path(topic_2)}']", text: topic_2_name)
end

Then /^the published policy should remain unchanged$/ do
  visit document_path(@edition.document_identity)
  assert page.has_css?('.document_view .title', text: @edition.title)
  assert page.has_css?('.document_view .body', text: @edition.body)
end

Then /^they should see the draft policy titled "([^"]*)"$/ do |title|
  edition = Edition.find_by_title(title)
  assert page.has_css?('.document_view .title', text: edition.title)
  assert page.has_css?('.document_view .body', text: edition.body)
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment a[href*='attachment.pdf']", text: /^attachment\.pdf$/)
end

Then /^I should see that "([^"]*)" and "([^"]*)" are responsible for the policy$/ do |role_1, role_2|
  assert page.has_css?("#ministers_responsible .role", text: role_1)
  assert page.has_css?("#ministers_responsible .role", text: role_2)
end

def pdf_attachment
  Rails.root.join("features/fixtures/attachment.pdf")
end