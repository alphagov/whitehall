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
  edition = create(:published_edition, title: policy_title)
  create(:topic, name: topic_1, editions: [edition])
  create(:topic, name: topic_2, editions: [edition])
end

Then /^I should see that the "([^"]*)" and "([^"]*)" topics are related$/ do |topic_1, topic_2|
  assert page.has_css?('#related_topics .topic', text: topic_1)
  assert page.has_css?('#related_topics .topic', text: topic_2)
end

When /^I create a new edition of the published policy$/ do
  Given %{I visit the list of published policies}
  click_link Edition.published.last.title
  click_button 'Create new draft'
end

Given /^I visit the list of published policies$/ do
  visit published_admin_editions_path
end

When /^I edit the new edition$/ do
  fill_in 'Title', with: "New title"
  fill_in 'Policy', with: "New policy"
  click_button 'Save'
end

Then /^the published policy should remain unchanged$/ do
  visit document_path(@edition.document)
  assert page.has_css?('.document_view .title', text: @edition.title)
  assert page.has_css?('.document_view .body', text: @edition.body)
end

Given /^"([^"]*)" has received an email requesting they fact check a draft policy titled "([^"]*)"$/ do |email, title|
  edition = create(:draft_edition, title: title)
  fact_check_request = edition.fact_check_requests.create(email_address: email)
  Notifications.fact_check(fact_check_request).deliver
end

When /^"([^"]*)" clicks the email link to the draft policy$/ do |email|
  When %{I open the last email sent to "#{email}"}
  And %{I click the first link in the email}
end

Then /^they should see the draft policy titled "([^"]*)"$/ do |title|
  edition = Edition.find_by_title(title)
  assert page.has_css?('.document_view .title', text: edition.title)
  assert page.has_css?('.document_view .body', text: edition.body)
end

Given /^a submitted policy titled "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(name: File.open(pdf_attachment))
  create(:submitted_edition, title: title, attachment: attachment)
end

Given /^a published policy titled "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(name: File.open(pdf_attachment))
  create(:published_edition, title: title, attachment: attachment)
end

When /^I visit the policy titled "([^"]*)"$/ do |title|
  edition = Edition.find_by_title(title)
  visit document_path(edition.document)
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment a[href*='attachment.pdf']", text: /^attachment\.pdf$/)
end

def pdf_attachment
  Rails.root.join("features/fixtures/attachment.pdf")
end