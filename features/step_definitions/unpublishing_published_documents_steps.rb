Given /^a published document exists with a slug that does not match the title$/ do
  @document = create(:published_policy, title: 'Some Policy')
  @original_slug = @document.slug
  @document.update_attributes(title: 'Published in error')
end

Given(/^there is a published document that is a duplicate of another page$/) do
  @existing_edition = create(:published_policy, title: 'An existing edition')
  @duplicate_edition = create(:published_policy, title: 'A duplicate edition')
end

When(/^I unpublish the duplicate, marking it as consolidated into the other page$/) do
  visit admin_edition_path(@duplicate_edition)
  click_button 'Unpublish'
  choose 'Unpublish: consolidated into another GOV.UK page'
  fill_in 'Alternative URL', with: Whitehall.url_maker.policy_url(@existing_edition.document)
  click_button 'Unpublish'
end

Then(/^I should be redirected to the other page when I view the document on the public site$/) do
  visit public_document_path(@duplicate_edition)
  assert_current_url policy_url(@existing_edition.document)
end

When /^I unpublish the document because it was published in error$/ do
  unpublish_edition(Edition.last)
end

Then(/^there should be an editorial remark recording the fact that the document was unpublished$/) do
  edition = Edition.last
  assert_equal 'Reset to draft', edition.editorial_remarks.last.body
end

Then /^I should see that the document was published in error on the public site$/ do
  edition = Edition.last
  visit public_document_path(edition)
  assert page.has_no_content?(edition.title)
  assert page.has_content?('The information on this page has been removed because it was published in error')
  assert page.has_content?('This page should never have existed')
  assert page.has_css?("a[href='#{Whitehall.url_maker.how_government_works_url}']")
end

Then /^I should see that the document was published in error at the original url$/ do
  visit policy_path(@original_slug)
  assert page.has_no_content?(@document.title)
  assert page.has_content?('The information on this page has been removed because it was published in error')
  assert page.has_content?('This page should never have existed')
  assert page.has_css?("a[href='#{Whitehall.url_maker.how_government_works_url}']")
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
