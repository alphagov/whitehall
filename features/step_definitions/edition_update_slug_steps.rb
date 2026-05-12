Then(/^I can see the preview URL of the publication "([^"]*)" contains "([^"]*)"$/) do |title, new_slug|
  visit admin_edition_path(Publication.latest_edition.find_by!(title:))
  expect(page).to have_link "Preview on website (opens in new tab)", href: "https://draft-origin.test.gov.uk/government/publications/#{new_slug}"
end

When(/^I reopen the draft of the publication "([^"]*)"$/) do |title|
  begin_editing_document(title)
end

Then(/^I cannot see the option to keep the current page URL$/) do
  expect(page).not_to have_field("Keep the current page URL")
end

Then(/^I can see the option to keep the current page URL$/) do
  expect(page).to have_css(".js-keep-slug-form-group:not([hidden])")
end

Then(/^the option to keep the current page URL is selected$/) do
  expect(page).to have_checked_field("Keep the current page URL")
end

Then(/^the option to update the page URL is selected$/) do
  expect(page).to have_checked_field("Update the page URL to match the new title")
end

Then(/^the keep-slug option shows the live URL$/) do
  live_edition = Publication.live_edition.first
  expect(page).to have_field("Keep the current page URL (#{live_edition.public_url})")
end
