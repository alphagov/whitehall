Given /^a published document exists with a slug that does not match the title$/ do
  @document = create(:published_policy, title: 'Some Policy')
  @original_slug = @document.slug
  @document.update_attributes(title: 'Published in error')
end

def unpublish_edition(edition)
  visit admin_edition_path(edition)
  click_button 'Unpublish'
  select 'Published in error', from: 'Reason for unpublishing'
  fill_in 'Further explanation', with: 'This page should never have existed'
  fill_in 'Alternative URL', with: 'https://www.gov.uk/government/how-government-works'
  yield if block_given?
  click_button 'Unpublish'
end

When /^I unpublish the document because it was published in error$/ do
  unpublish_edition(Edition.last)
end

Then /^I should see that the document was published in error on the public site$/ do
  edition = Edition.last
  visit public_document_path(edition)
  assert page.has_no_content?(edition.title)
  assert page.has_content?('The information on this page has been removed because it was published in error')
  assert page.has_content?('This page should never have existed')
  assert page.has_css?('a[href="https://www.gov.uk/government/how-government-works"]')
end

Then /^I should see that the document was published in error at the original url$/ do
  visit policy_path(@original_slug)
  assert page.has_no_content?(@document.title)
  assert page.has_content?('The information on this page has been removed because it was published in error')
  assert page.has_content?('This page should never have existed')
  assert page.has_css?('a[href="https://www.gov.uk/government/how-government-works"]')
end

When /^I unpublish the document and ask for a redirect$/ do
  unpublish_edition(Edition.last) do
    check 'Redirect to URL automatically?'
  end
end

Then /^I should be redirected to the new url when I view the document on the public site$/ do
  edition = Edition.last

  visit public_document_path(edition)
  assert_current_url edition.unpublishing.alternative_url
end
