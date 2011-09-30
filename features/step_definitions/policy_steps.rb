Given /^"([^"]*)" submitted "([^"]*)" with body "([^"]*)"$/ do |author, title, body|
  Given %{I am logged in as a writer called "#{author}"}
  And %{I visit the new policy page}
  And %{I write and save a policy called "#{title}" with body "#{body}"}
  And %{I submit the policy for the second set of eyes}
end

Then /^the policy "([^"]*)" should( not)? be visible to the public$/ do |policy_title, invert|
  visit policies_path
  published_policy_selector = ["#published_policies .policy .title", text: policy_title]
  if invert.nil?
    assert page.has_css?(*published_policy_selector)
    click_link policy_title
    assert page.has_css?(".policy_document .title", text: policy_title)
  else
    assert page.has_no_css?(*published_policy_selector)
  end
end

When /^another user changes the title from "([^"]*)" to "([^"]*)"$/ do |old_title, new_title|
  policy = Edition.find_by_title(old_title)
  policy.update_attributes(:title => new_title)
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
  visit policy_path(@edition.document)
  assert page.has_css?('.policy_document .title', text: @edition.title)
  assert page.has_css?('.policy_document .body', text: @edition.body)
end

Given /^"([^"]*)" has received an email requesting they fact check a draft policy titled "([^"]*)"$/ do |email, title|
  edition = create(:draft_edition, :title => title)
  fact_check_request = edition.fact_check_requests.create(:email_address => email)
  Notifications.fact_check(fact_check_request).deliver
end

When /^"([^"]*)" clicks the email link to the draft policy$/ do |email|
  When %{I open the last email sent to "#{email}"}
  And %{I click the first link in the email}
end

Then /^they should see the draft policy titled "([^"]*)"$/ do |title|
  edition = Edition.find_by_title(title)
  assert page.has_css?('.policy .title', :text => edition.title)
  assert page.has_css?('.policy .body', :text => edition.body)
end

When /^I attach a PDF file to the policy$/ do
  attach_file "Attachment", pdf_attachment
end

Given /^a draft policy titled "([^"]*)" with a PDF attachment$/ do |title|
  attachment = File.open(pdf_attachment)
  create(:draft_edition, title: title, attachment: attachment)
end

Given /^a submitted policy titled "([^"]*)" with a PDF attachment$/ do |title|
  attachment = File.open(pdf_attachment)
  create(:submitted_edition, title: title, attachment: attachment)
end

Given /^a published policy titled "([^"]*)" with a PDF attachment$/ do |title|
  attachment = File.open(pdf_attachment)
  create(:published_edition, title: title, attachment: attachment)
end

When /^I visit the policy titled "([^"]*)"$/ do |title|
  edition = Edition.find_by_title(title)
  visit policy_path(edition.document)
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment a[href*='attachment.pdf']", :text => /^attachment\.pdf$/)
end

def pdf_attachment
  Rails.root.join("features/fixtures/attachment.pdf")
end