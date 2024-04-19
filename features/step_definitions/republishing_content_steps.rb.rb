Given(/^the "Past prime ministers" page can be republished$/) do
  create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
end

When(/^I request a republish of the "Past prime ministers" page$/) do
  visit admin_republishing_index_path
  find("#republish-past-prime-ministers").click
  click_button("Confirm republishing")
end

Then(/^I can see the "Past prime ministers" page has been scheduled for republishing/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "The 'Past Prime Ministers' page has been scheduled for republishing")
end

Given(/^a published organisation "An Existing Organisation" exists$/) do
  create(:organisation, name: "An Existing Organisation", slug: "an-existing-organisation")
end

Given(/^the "An Existing Organisation" organisation can be republished$/) do
  create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
end

When(/^I request a republish of the "An Existing Organisation" organisation$/) do
  visit admin_republishing_index_path
  find("#republish-organisation").click
  fill_in "Enter the slug for the organisation", with: "an-existing-organisation"
  click_button("Continue")
  click_button("Confirm republishing")
end

Then(/^I can see the "An Existing Organisation" organisation has been scheduled for republishing/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "The 'An Existing Organisation' organisation has been scheduled for republishing")
end
