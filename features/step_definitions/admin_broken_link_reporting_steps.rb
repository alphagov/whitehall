Given(/^a draft document with broken links exists$/) do
  @broken_link   = 'http://broken-link.com/404'
  @working_link = 'http://example.com/some/page'
  stub_request(:get, @broken_link).to_return(status: 404)
  stub_request(:get, @working_link).to_return(status: 200)

  @edition = create(:draft_speech, body: govspeak_with_links(@broken_link, @working_link))
end

When(/^I check the document for broken links$/) do
  visit admin_edition_path(@edition)
  click_on 'Find broken links'
end

Then(/^I should a list of the broken links$/) do
  assert page.has_content?("We've found some links that may not be responding:")
  assert page.has_link?(@broken_link, href: @broken_link)
end
