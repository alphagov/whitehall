Then(/^I can see the preview URL of the publication "([^"]*)" contains "([^"]*)"$/) do |title, new_slug|
  visit admin_edition_path(Publication.latest_edition.find_by!(title:))
  expect(page).to have_link "Preview on website (opens in new tab)", href: "https://draft-origin.test.gov.uk/government/publications/#{new_slug}"
end

Then(/^I cannot see the option to keep the current page URL$/) do
  expect(page).not_to have_field("Keep current URL")
end

Then(/^I can see the option to keep the current page URL$/) do
  expect(page).to have_css(".js-url-radio-group:not([hidden])")
end

Then(/^the saved URL choice for "([^"]*)" is reflected when revisiting the edit page$/) do |title|
  draft = Publication.latest_edition.find_by!(title:)
  visit edit_admin_edition_path(draft)
  expected_choice = draft.slug_override.present? ? "Keep current URL" : "Update URL to match title"
  expect(page).to have_checked_field(expected_choice)
end
