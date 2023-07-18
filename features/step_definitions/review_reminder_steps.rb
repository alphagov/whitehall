And(/^I add a review date of "([^"]*)" and the email address "([^"]*)" on the edit page$/) do |date, email|
  click_link "Edit draft"
  check "Set a reminder to review this content after it has been published"
  within_conditional_reveal "Set a reminder to review this content after it has been published" do
    fill_in_date_fields(date)
    fill_in "Email address", with: email
  end
  click_button "Save and continue"
  click_button "Update tags"
end

And(/^I add a review date of "([^"]*)" and the email address "([^"]*)"$/) do |date, email|
  fill_in_date_fields(date)
  fill_in "Email address (required)", with: email
  click_button "Save"
end

Then(/^I should see the review date of "([^"]*)" on the edition summary page$/) do |date|
  assert_selector ".app-view-summary__section .govuk-summary-list__row:nth-child(5) .govuk-summary-list__key", text: "Review date"
  assert_selector ".app-view-summary__section .govuk-summary-list__row:nth-child(5) .govuk-summary-list__value", text: date
end

When(/^I click the button "([^"]*)" on the edition summary page for "([^"]*)"$/) do |label, title|
  edition = Edition.find_by!(title:)
  visit admin_edition_path(edition)
  click_on label
end

And(/^a review reminder exists for "([^"]*)" with the date "([^"]*)"$/) do |title, date|
  edition = Edition.find_by!(title:)
  create(:review_reminder, document: edition.document, review_at: date)
end

And(/^I update the review date to "([^"]*)"$/) do |date|
  fill_in_date_fields(date)
  click_button "Save"
end
