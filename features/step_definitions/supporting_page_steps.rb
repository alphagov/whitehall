Given /^a supporting page "([^"]*)" exists on a draft policy "([^"]*)"$/ do |supporting_title, document_title|
  edition = create(:draft_policy, title: document_title)
  create(:supporting_page, edition: edition, title: supporting_title)
end

Given /^a draft policy "([^"]*)" with supporting pages "([^"]*)" and "([^"]*)"$/ do |policy_title, first_supporting_title, second_supporting_title|
  edition = create(:draft_policy, title: policy_title)
  create(:supporting_page, edition: edition, title: first_supporting_title)
  create(:supporting_page, edition: edition, title: second_supporting_title)
end

Given /^I start editing the supporting page "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  supporting_page = SupportingPage.find_by_title!(original_title)
  visit admin_supporting_page_path(supporting_page)
  click_link "Edit"
  fill_in "Title", with: new_title
end

Given /^another user edits the supporting page "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  supporting_page = SupportingPage.find_by_title!(original_title)
  supporting_page.update_attributes!(title: new_title)
end

When /^I save my changes to the supporting page$/ do
  click_button "Save"
end

When /^I edit the supporting page "([^"]*)" changing the title to "([^"]*)"$/ do |original_title, new_title|
  supporting_page = SupportingPage.find_by_title!(original_title)
  visit admin_edition_path(supporting_page.edition)
  click_link original_title
  click_link "Edit"
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I add a supporting page "([^"]*)" to the "([^"]*)" policy$/ do |supporting_title, policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_link "Add supporting page"
  fill_in "Title", with: supporting_title
  fill_in "Body", with: "Some supporting information"
  click_button "Save"
end

When /^I add a supporting page "([^"]*)" with an attachment to the "([^"]*)" policy$/ do |title, policy_title|
  policy = Policy.find_by_title!(policy_title)
  visit admin_edition_path(policy)
  click_link "Add supporting page"
  fill_in "Title", with: title
  fill_in "Body", with: "Some supporting information\n\n!@1"
  within ".attachments" do
    fill_in "Title", with: "Attachment Title"
    attach_file "File", Rails.root.join("features/fixtures/attachment.pdf")
  end
  click_button "Save"
end


When /^I edit the supporting page changing the title to "([^"]*)"$/ do |new_title|
  fill_in "Title", with: new_title
  click_button "Save"
end

When /^I remove the supporting page "([^"]*)" from "([^"]*)"$/ do |supporting_page_title, title|
  visit_document_preview title
  click_link supporting_page_title
  click_button "Remove"
end

Then /^I should see the conflict between the supporting page titles "([^"]*)" and "([^"]*)"$/ do |new_title, latest_title|
  assert page.has_css?(".conflicting.new #supporting_page_title", value: new_title)
  assert page.has_css?(".conflicting.latest #supporting_page_title[disabled]", value: latest_title)
end

Then /^I should see in the preview that "([^"]*)" includes the "([^"]*)" supporting page$/ do |title, supporting_title|
  visit_document_preview title
  assert has_css?(".supporting_page", text: supporting_title)
  click_link supporting_title
  assert has_css?(".title", text: supporting_title)
end

Then /^I should see that the "([^"]*)" policy's "([^"]*)" supporting page has an attachment$/ do |title, supporting_title|
  visit_document_preview title
  click_link supporting_title
  assert page.has_css?(".attachment a[href*='attachment.pdf']", text: "Attachment Title")
end

Then /^I should see in the list of draft documents that "([^"]*)" has supporting page "([^"]*)"$/ do |title, supporting_page_title|
  visit admin_editions_path(state: :draft)
  click_link "Show documents by everyone"
  edition = Edition.find_by_title!(title)
  within(record_css_selector(edition)) do
    assert has_css?(".supporting_pages", text: /#{supporting_page_title}/)
  end
end

Then /^I should see in the preview that the only supporting page for "([^"]*)" is "([^"]*)"$/ do |title, supporting_page_title|
  visit_document_preview title
  assert has_css?(".supporting_pages .supporting_page", count: 1)
  assert has_css?(".supporting_pages", text: /#{supporting_page_title}/)
end
