When /^I unpublish the document because it was published in error$/ do
  edition = Edition.last
  visit admin_edition_path(edition)
  click_button 'Unpublish'
  select 'Published in error', from: 'Reason for unpublishing'
end

Then /^the document should not be visible to the public, with the reason why given$/ do
  edition = Edition.last
  visit public_document_path(edition)
  assert_equal 410, page.status_code
  assert page.has_content?('The information on this page has been removed because it was published in error')
end
