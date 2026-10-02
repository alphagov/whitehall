When(/^I navigate to the new document page$/) do
  create(:organisation) if Organisation.count.zero?
  visit admin_root_path
  find("li.app-c-sub-navigation__list-item a", text: "New document").click
  page.choose("Publication")
  click_button("Next")
end

Then(/^I should see the Content Block Picker has been instantiated$/) do
  expect(page).to have_selector(".content-block-highlight__preview", visible: false)
end

Then(/^I should see the Content Block Picker has not been instantiated$/) do
  expect(page).not_to have_selector(".content-block-highlight__preview", visible: false)
end
