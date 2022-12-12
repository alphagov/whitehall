And(/^I visit the edit slug page for "([^"]*)"$/) do |edition_title|
  @edition = Edition.find_by!(title: edition_title)
  visit edit_slug_admin_edition_path(@edition)
end

And(/^I update the slug to "([^"]*)"$/) do |new_slug|
  fill_in "Slug", with: new_slug
  click_button "Update"
end

Then(/^I can see the slug has been updated to "([^"]*)"$/) do |new_slug|
  visit admin_edition_path(@edition)
  if using_design_system?
    click_button "Create new edition"
  else
    click_button "Create new edition to edit"
  end
  expect(find("#edition_slug").value).to eq new_slug
end

Then(/^I am told I do not have access to the document$/) do
  expect(page).to have_content "Sorry, you don’t have access to this document"
end
