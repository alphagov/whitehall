Given(/^a draft document with broken links exists$/) do
  @broken_link   = 'http://broken-link.com/404'
  @working_link = 'http://example.com/some/page'

  link_checker_api_stub_create_batch(
    id: 1,
    status: "in_progess",
    links: [
      { uri: @broken_link, status: "pending" },
      { uri: @working_link, status: "pending" },
    ]
  )

  @edition = create(:draft_speech, body: govspeak_with_links(@broken_link, @working_link))
end

When(/^I check the document for broken links$/) do
  visit admin_edition_path(@edition)
  click_on 'Check for broken links'

  # Wait until the check is in progress
  page.has_content?("Please wait")
  link_checker_api_call_webhook(
    id: 1,
    links: [
      { uri: @broken_link, status: "broken" },
      { uri: @working_link, status: "ok" },
    ]
  )
end

Then(/^I should see a list of the broken links$/) do
  assert page.has_content?("links in this document that may be broken")
  assert page.has_link?(@broken_link, href: @broken_link)
end

When(/^I correct the broken links$/) do
  fixed_link = 'http://fixed-link.com'

  link_checker_api_stub_create_batch(
    id: 2,
    status: "in_progess",
    links: [
      { uri: fixed_link, status: "pending" },
      { uri: @working_link, status: "pending" },
    ]
  )

  click_on "Edit draft"
  fill_in  "Body", with: govspeak_with_links(fixed_link, @working_link)
  click_on "Save"

  # Wait until the check is in progress
  page.has_content?("Please wait")

  link_checker_api_call_webhook(
    id: 2,
    links: [
      { uri: fixed_link, status: "ok" },
      { uri: @working_link, status: "ok" },
    ]
  )
end

Then(/^I should see that the document has no broken links$/) do
  assert page.has_content?("This document contains no broken links")
end
