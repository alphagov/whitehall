When(/^I view the current edition of document "([^"]*)"$/) do |title|
  @edition = Edition.find_by(title:).document.editions.last
  visit admin_edition_path(@edition)
end

Then(/^I am told I do not have permissions to access this page/) do
  expect(page).to have_content "You do not have permission to access this page."
end

Then(/^I should not see a link to edit the access/) do
  expect(page).not_to have_link("As an administrator, you can update the access permissions of the page.", href: edit_access_limited_admin_edition_path(@edition))
end

Then(/^I should see a link to edit the access/) do
  expect(page).to have_link("As an administrator, you can update the access permissions of the page.", href: edit_access_limited_admin_edition_path(@edition))
end
