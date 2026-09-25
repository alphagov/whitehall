When(/^I manually navigate to the 'new document' screen with a parent_edition_id param set$/) do
  visit "/government/admin/new-document?parent_edition_id=#{@edition.id}"
end

When(/^I visit the document summary page of the standard edition called "([^"]*)" with a parent_edition_id param of "([^"]*)" set$/) do |title, parent_title|
  edition = Edition.find_by(title: "\"#{title}\"")
  parent_edition = Edition.find_by(title: "\"#{parent_title}\"")

  visit "/government/admin/standard-editions/#{edition.id}?parent_edition_id=#{parent_edition.id}"
end

Then(/^the document should be created$/) do
  expect(page).to have_css(".govuk-notification-banner__heading", text: "Your document has been saved")
end

When(/^I manually navigate to a 'new document' screen with an invalid parent_edition_id param set$/) do
  create(:organisation) if Organisation.count.zero? # Getting ready for the form
  visit "/government/admin/standard-editions/new?configurable_document_type=test_type&parent_edition_id=-1"
end

Then(/^the document should fail to save$/) do
  expect(Edition.count).to eq(0)
end

Then(/^I should see a banner that displays the current parent edition$/) do
  expect(page).to have_css(".app-c-child-of-banner__part-of", text: "Child of")
  expect(page).to have_css(".app-c-child-of-banner__title", text: @edition.title)
  expect(page).to have_css(".app-c-child-of-banner__link[href='#{admin_edition_path(@edition)}']", text: "Edit child pages")
end

Then(/^I should not see a banner that displays the parent edition titled "([^"]*)"$/) do |title|
  Edition.find_by(title: "\"#{title}\"")

  expect(page).to_not have_css(".app-c-child-of-banner__part-of", text: "Child of")
  expect(page).to_not have_css(".app-c-child-of-banner__title", text: @edition.title)
  expect(page).to_not have_css(".app-c-child-of-banner__link[href='#{admin_edition_path(@edition)}']", text: "Edit child pages")
end

Then(/^I should see a banner that displays the parent edition titled "([^"]*)"$/) do |title|
  edition = Edition.find_by(title: "\"#{title}\"")

  expect(page).to have_css(".app-c-child-of-banner__part-of", text: "Child of")
  expect(page).to have_css(".app-c-child-of-banner__title", text: edition.title)
  expect(page).to have_css(".app-c-child-of-banner__link[href='#{admin_edition_path(edition)}']", text: "Edit child pages")
end

And(/^I should see an error message describing the corrupt parent edition ID$/) do
  expect(page).to have_content("Parent edition must correspond to an existing StandardEdition")
end
