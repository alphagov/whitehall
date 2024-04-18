Given(/^the "Past prime ministers" page can be republished$/) do
  create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
end

When(/^I request a republish of the "Past prime ministers" page$/) do
  visit admin_republishing_index_path
  find("#republish-past-prime-ministers").click
  click_button("Confirm republishing")
end

Then(/^I can see the "Past prime ministers" page has been scheduled for republishing/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "'Past Prime Ministers' page has been scheduled for republishing")
end
