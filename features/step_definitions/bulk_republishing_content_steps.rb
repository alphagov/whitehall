Given(/^Documents exist$/) do
  2.times { create(:document) }
end

When(/^I request a bulk republishing of all documents$/) do
  visit admin_republishing_index_path
  find("#all-documents").click
  fill_in "What is the reason for republishing?", with: "It needs republishing"
  click_button("Confirm republishing")
end

Then(/^I can see that all documents have been queued for republishing$/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "All documents have been queued for republishing")
end

Given(/^Published Organisation "About Us" pages exist$/) do
  2.times { create(:about_corporate_information_page) }
end

When(/^I request a bulk republishing of the Organisation "About Us" pages$/) do
  visit admin_republishing_index_path
  find("#all-organisation-about-us-pages").click
  fill_in "What is the reason for republishing?", with: "It needs republishing"
  click_button("Confirm republishing")
end

Then(/^I can see the Organisation "About Us" pages have been queued for republishing$/) do
  expect(page).to have_selector(".gem-c-success-alert", text: "All organisation 'About Us' pages have been queued for republishing")
end
