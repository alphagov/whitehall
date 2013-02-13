When /^I unpublish the document because it was published in error$/ do
  edition = Edition.last
  visit admin_edition_path(edition)
  click_button 'Unpublish'
  select 'Published in error', from: 'Reason for unpublishing'
  fill_in 'Additional explanation', with: 'This page should never have existed'
  fill_in 'Alternative URL', with: 'https://www.gov.uk/some/alternative/page'
  click_button 'Unpublish'
end

Then /^the document should not be visible to the public, with the reason why given$/ do
  edition = Edition.last
  visit public_document_path(edition)
  refute page.has_content?(edition.title)
  assert page.has_content?('The information on this page has been removed because it was published in error')
end
