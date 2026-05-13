Then(/^I can see the preview URL of the publication "([^"]*)" contains "([^"]*)"$/) do |title, new_slug|
  visit admin_edition_path(Publication.latest_edition.find_by!(title:))
  expect(page).to have_link "Preview on website (opens in new tab)", href: "https://draft-origin.test.gov.uk/government/publications/#{new_slug}"
end

Then(/^I cannot see the option to keep the current page URL$/) do
  expect(page).not_to have_field("Keep current URL")
end

Then(/^I can see the option to keep the current page URL$/) do
  expect(page).to have_css(".js-keep-slug-form-group:not([hidden])")
end

Then(/^the saved URL choice is reflected on re-entering the edit page$/) do
  draft = Publication.where(state: "draft").last
  visit edit_admin_edition_path(draft)
  expected_choice = draft.slug_override.present? ? "Keep current URL" : "Update URL to match title"
  expect(page).to have_checked_field(expected_choice)
end

Given(/^the publication "([^"]*)" has been renamed to "([^"]*)" with the original URL kept$/) do |original_title, new_title|
  step %(a published publication "#{original_title}" exists)
  step %(I edit the publication "#{original_title}")
  step %(I change the title to "#{new_title}")
  step %(I save the edition and go to the document summary)
  step %(I force publish the publication "#{new_title}")
end

Given(/^the publication "([^"]*)" has been renamed to "([^"]*)" with the URL updated to match the new title$/) do |original_title, new_title|
  step %(a published publication "#{original_title}" exists)
  step %(I edit the publication "#{original_title}")
  step %(I change the title to "#{new_title}")
  step %(I opt out of keeping the live slug)
  step %(I save the edition and go to the document summary)
  step %(I force publish the publication "#{new_title}")
end
