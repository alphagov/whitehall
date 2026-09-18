When(/^I manually navigate to the 'new document' screen with a parent_edition_id param set$/) do
  visit "/government/admin/new-document?parent_edition_id=#{@edition.id}"
end

Then(/^the document should be created$/) do
  expect(page).to have_css(".govuk-notification-banner__heading", text: "Your document has been saved")
end

# TODO: we'll make this a visual check one day, e.g. when we build the
# "Child of <Parent title>" component
Then(/^the document should be designated a child of the parent document$/) do
  child_edition = Edition.last
  expect(child_edition.parent_edition).to eq(@edition)
end

When(/^I manually navigate to a 'new document' screen with an invalid parent_edition_id param set$/) do
  create(:organisation) if Organisation.count.zero? # Getting ready for the form
  visit "/government/admin/standard-editions/new?configurable_document_type=test_type&parent_edition_id=-1"
end

Then(/^the document should fail to save$/) do
  expect(Edition.count).to eq(0)
end

And(/^I should see an error message describing the corrupt parent edition ID$/) do
  expect(page).to have_content("Parent edition must correspond to an existing StandardEdition")
end
