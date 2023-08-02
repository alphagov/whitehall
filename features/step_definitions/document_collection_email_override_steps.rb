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
