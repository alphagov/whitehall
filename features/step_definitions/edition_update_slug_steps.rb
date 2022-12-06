And(/^I visit the edit slug page for "([^"]*)"$/) do |edition_title|
  @edition = Edition.find_by!(title: edition_title)
  visit admin_edit_admin_document_slug_path(@edition.document)
end

And(/^I update the slug to "([^"]*)"$/) do |new_slug|
  fill_in "Slug", with: new_slug
  click_button "Update"
end

Then(/^I can see the slug has been updated to "([^"]*)"$/) do |new_slug|
  visit admin_edition_path(@edition)
  click_button "Create new edition to edit"
  expect(find("#edition_slug").value).to eq new_slug
end

Then(/^I am told I do not have access to the document$/) do
  expect(page).to have_content "Sorry, you don’t have access to this document"
end
