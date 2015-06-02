Given /^a published document exists with a slug that does not match the title$/ do
  @document = create(:published_publication, title: 'Some Publication')
  @original_slug = @document.slug
  @document.update_attributes(title: 'Published in error')
end

Given(/^there is a published document that is a duplicate of another page$/) do
  @existing_edition = create(:published_publication, title: 'An existing edition')
  @duplicate_edition = create(:published_publication, title: 'A duplicate edition')
end

When(/^I unpublish the duplicate, marking it as consolidated into the other page$/) do
  visit admin_edition_path(@duplicate_edition)
  click_on 'Withdraw or unpublish'
  choose 'Unpublish: consolidated into another GOV.UK page'

  within '#js-consolidated-form' do
    fill_in 'consolidated_alternative_url', with: Whitehall.url_maker.publication_url(@existing_edition.document)
    click_button 'Unpublish'
  end
end

When(/^I withdraw the publication because it is no longer government publication$/) do
  @publication = Publication.last
  visit admin_edition_path(@publication)
  click_on 'Withdraw or unpublish'
  choose 'Withdraw: no longer current government policy/activity'
  fill_in 'Public explanation (this is shown on the live site) *', with: 'We no longer believe people should shave'
  click_button 'Withdraw'

  assert_equal :withdrawn, @publication.reload.current_state
end

When(/^I edit the public explanation for withdrawal$/) do
  publication = Publication.last
  visit admin_edition_path(publication)
  click_on 'Edit withdrawal explanation'
  fill_in 'Public explanation', with: "We believe people should shave, but the government need not enforce a publication for that"
  click_button 'Update withdrawal explanation'
end

Then(/^I should see the updated explanation on the public site$/) do
  step %{the publication should be marked as withdrawn on the public site}
end

Then(/^the publication should be marked as withdrawn on the public site$/) do
  publication = Publication.last
  visit public_document_path(publication)
  assert page.has_content?(publication.title)
  assert page.has_content?('This publication was withdrawn')
  assert page.has_content?(publication.unpublishing.explanation)
end

Then(/^I should be redirected to the other page when I view the document on the public site$/) do
  visit public_document_path(@duplicate_edition)
  assert_path publication_path(@existing_edition.document)
end

When /^I unpublish the document because it was published in error$/ do
  unpublish_edition(Edition.last)
end

Then(/^there should be an editorial remark recording the fact that the document was unpublished$/) do
  edition = Edition.last
  assert_equal 'Reset to draft', edition.editorial_remarks.last.body
end

Then(/^there should be an editorial remark recording the fact that the document was withdrawn$/) do
  edition = Edition.last
  assert_equal 'Withdrawn', edition.editorial_remarks.last.body
end

Then /^I should see that the document was published in error on the public site$/ do
  edition = Edition.last
  visit public_document_path(edition)
  assert page.has_no_content?(edition.title)
  assert page.has_content?('The information on this page has been removed because it was published in error')
  assert page.has_content?('This page should never have existed')
end

Then /^I should see that the document was published in error at the original url$/ do
  visit publication_path(@original_slug)
  assert page.has_no_content?(@document.title)
  assert page.has_content?('The information on this page has been removed because it was published in error')
  assert page.has_content?('This page should never have existed')
end

When /^I unpublish the document and ask for a redirect$/ do
  unpublish_edition(Edition.last) do
    fill_in 'published_in_error_alternative_url', with: Whitehall.url_maker.how_government_works_url
    check 'Redirect to URL automatically?'
  end
end

Then /^I should be redirected to the new url when I view the document on the public site$/ do
  edition = Edition.last

  visit public_document_path(edition)
  assert_current_url edition.unpublishing.alternative_url
end

Then /^I should not be able to discard the draft resulting from the unpublishing$/ do
  visit admin_edition_path(Edition.last)
  refute page.has_button?('Discard draft')
end
