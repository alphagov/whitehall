Given(/^I am a user with email override editor permissions/) do
  @user = build(:user, permissions: [User::Permissions::EMAIL_OVERRIDE_EDITOR], organisation_slug: "gds")
  login_as(@user)
end

And(/^a draft document collection published by my organisation exists/) do
  @document_collection = create(:draft_document_collection)
end

When(/^I visit the edit document collection page/) do
  visit edit_admin_document_collection_path(@document_collection)
end

Then(/^I click on the tab "Email notifications/) do
  expect(page).to have_content("Email notifications")
  click_on("Email notifications")
  expect(page).to have_content("\nEmails about this page\n")
  expect(page).to have_content("\nEmails about the topic\n")
end

And(/^I choose "Emails about this topic"/) do
  page.choose(name: "override_email_subscriptions", option: "true")
end

And(/^I select "([^"]*)"$/) do |topic_label|
  select topic_label, from: "selected_taxon_content_id"
end

And(/^I click the checkbox to confirm my selection./) do
  check("email_override_confirmation-0")
end

And(/^I click "Save"/) do
  click_on("Save")
end

Then(/^I am redirected to the document collection edit page/) do
  assert_current_path edit_admin_document_collection_path(@document_collection)
end
