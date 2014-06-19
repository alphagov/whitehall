Given(/^a draft document with broken links exists$/) do
  @broken_link   = 'http://broken-link.com/404'
  @working_link = 'http://example.com/some/page'
  stub_request(:get, @broken_link).to_return(status: 404)
  stub_request(:get, @working_link).to_return(status: 200)

  @edition = create(:draft_speech, body: govspeak_with_links(@broken_link, @working_link))
end

When(/^I check the document for broken links$/) do
  visit admin_edition_path(@edition)
  click_on 'Check for broken links'
end

Then(/^I should a list of the broken links$/) do
  assert page.has_content?("links in this document that may be broken")
  assert page.has_link?(@broken_link, href: @broken_link)
end

When(/^I correct the broken links$/) do
  fixed_link = 'http://fixed-link.com'
  stub_request(:get, fixed_link).to_return(status: 200)

  click_on "Edit draft"
  fill_in  "Body", with: govspeak_with_links(fixed_link, @working_link)
  click_on "Save"
end

Then(/^I should see that the document has no broken links$/) do
  assert page.has_content?("This document contains no broken links")
end
