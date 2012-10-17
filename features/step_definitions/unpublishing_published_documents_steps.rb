When /^I unpublish the document "([^"]*)"$/ do |title|
  edition = Edition.find_by_title!(title)
  visit admin_edition_path(edition)
  click_button "Unpublish"
end

Then /^the document "([^"]*)" should not be visible to the public$/ do |title|
  edition = Edition.find_by_title!(title)
  visit public_document_path(edition)
  assert_equal 404, page.status_code
end