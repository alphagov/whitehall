Given(/^a published document exists with a slug that does not match the title$/) do
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

When(/^I withdraw the publication with the explanation "([^"]*)"$/) do |explanation|
  @publication = Publication.last
  visit admin_edition_path(@publication)
  click_on 'Withdraw or unpublish'
  choose 'Withdraw: no longer current government policy/activity'
  fill_in 'Public explanation (this is shown on the live site) *', with: explanation
  click_button 'Withdraw'

  assert_equal :withdrawn, @publication.reload.current_state
end

When(/^I edit the public explanation for withdrawal to "([^"]*)"$/) do |explanation|
  publication = Publication.last
  visit admin_edition_path(publication)
  click_on 'Edit withdrawal explanation'
  fill_in 'Public explanation', with: explanation
  click_button 'Update withdrawal explanation'
end

Then(/^the unpublishing should redirect to the existing edition$/) do
  unpublishing = @duplicate_edition.unpublishing
  path = publication_path(@existing_edition.document)
  assert unpublishing.alternative_url.end_with?(path)
end

When(/^I unpublish the document because it was published in error$/) do
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

Then(/^there should be an unpublishing explanation of "([^"]*)" and a reason of "([^"]*)"$/) do |explanation, reason_name|
  edition = Edition.last
  unpublishing = edition.unpublishing

  assert unpublishing.present?

  reason = unpublishing.unpublishing_reason

  assert_equal explanation, unpublishing.explanation
  assert_equal reason_name, reason.name
end

When(/^I unpublish the document and ask for a redirect to "([^"]*)"$/) do |url|
  unpublish_edition(Edition.last) do
    fill_in 'published_in_error_alternative_url', with: url
    check 'Redirect to URL automatically?'
  end
end

Then(/^the unpublishing should redirect to "([^"]*)"$/) do |url|
  edition = Edition.last

  unpublishing = edition.unpublishing

  assert unpublishing.redirect
  assert_equal url, unpublishing.alternative_url
end

Then(/^I should not be able to discard the draft resulting from the unpublishing$/) do
  visit admin_edition_path(Edition.last)
  refute page.has_button?('Discard draft')
end
