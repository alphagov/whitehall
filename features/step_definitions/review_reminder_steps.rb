And(/^I add a review date of "([^"]*)" and the email address "([^"]*)" on the edit page$/) do |date, email|
  click_link "Edit draft"
  check "Set a reminder to review this content after it has been published"
  within_conditional_reveal "Set a reminder to review this content after it has been published" do
    fill_in_date_fields(date)
    fill_in "Email address", with: email
  end
  click_button "Save and go to document summary"
end

And(/^I add a review date of "([^"]*)" and the email address "([^"]*)"$/) do |date, email|
  fill_in_date_fields(date)
  fill_in "Email address (required)", with: email
  click_button "Save"
end

Then(/^I should see the review date of "([^"]*)" on the edition summary page$/) do |date|
  assert_selector ".app-view-summary__section .govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Review date"
  assert_selector ".app-view-summary__section .govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: date
end

Then(/^I should see the review date of "([^"]*)" on the deletion confirmation page$/) do |date|
  assert_selector ".govuk-body", text: "Review date: #{date}"
end

Then(/^I should not see a review date on the edition summary page$/) do
  assert_selector ".app-view-summary__section .govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Review date"
  assert_selector ".app-view-summary__section .govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: "Not set"
end

When(/^I click the button "([^"]*)" on the edition summary page for "([^"]*)"$/) do |label, title|
  edition = Edition.find_by!(title:)
  visit admin_edition_path(edition)
  click_on label
end

When(/^I click the link "([^"]*)" on the edition summary page for "([^"]*)"$/) do |label, title|
  edition = Edition.find_by!(title:)
  visit admin_edition_path(edition)
  click_link label
end

And(/^a review reminder exists for "([^"]*)" with the date "([^"]*)"$/) do |title, date|
  edition = Edition.find_by!(title:)
  create(:review_reminder, document: edition.document, review_at: date)
end

And(/^I update the review date to "([^"]*)"$/) do |date|
  fill_in_date_fields(date)
  click_button "Save"
end

And(/^a review reminder exists for "([^"]*)" and the review date has passed$/) do |title|
  edition = Edition.find_by!(title:)
  create(:review_reminder, :reminder_due, document: edition.document)
end

When(/^I filter by review overdue$/) do
  visit admin_editions_path
  check "Review overdue"
  click_on "Search"
end

And(/^I delete the review date$/) do
  click_button "Delete"
end
