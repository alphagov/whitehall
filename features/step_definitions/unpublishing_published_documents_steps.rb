Given /^a published document exists with a slug that does not match the title$/ do
  @document = create(:published_policy, title: 'Some Policy')
  @original_slug = @document.slug
  @document.update_attribute(:title, 'Published in error')
end

When /^I unpublish the document because it was published in error$/ do
  edition = Edition.last
  visit admin_edition_path(edition)
  click_button 'Unpublish'
  select 'Published in error', from: 'Reason for unpublishing'
  fill_in 'Further explanation', with: 'This page should never have existed'
  fill_in 'Alternative URL', with: 'https://www.gov.uk/some/alternative/page'
  click_button 'Unpublish'
end

Then /^I should see that the document was published in error on the public site$/ do
  edition = Edition.last
  visit public_document_path(edition)
  refute page.has_content?(edition.title)
  assert page.has_content?('The information on this page has been removed because it was published in error')
  assert page.has_content?('This page should never have existed')
  assert page.has_content?('https://www.gov.uk/some/alternative/page')
end

Then /^I should see that the document was published in error at the original url$/ do
  visit policy_path(@original_slug)
  refute page.has_content?(@document.title)
  assert page.has_content?('The information on this page has been removed because it was published in error')
  assert page.has_content?('This page should never have existed')
  assert page.has_content?('https://www.gov.uk/some/alternative/page')
end