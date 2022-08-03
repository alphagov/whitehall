When(/^I request a review from "([^"]*)" with the instructions "([^"]*)" for the document "([^"]*)"$/) do |email_address, extra_instructions, document_title|
  @edition = create(:draft_publication, title: document_title)
  @email_address = email_address
  @extra_instructions = extra_instructions

  visit admin_edition_path(@edition)
  click_link "Fact checking"
  click_link "Request fact check"
  fill_in "Email address", with: @email_address
  fill_in "Extra instructions", with: @extra_instructions
  click_button "Send request"
end

Then(/^I should see I have a pending fact check request$/) do
  ensure_path admin_edition_fact_check_requests_path(@edition)
  expect(page).to have_selector(".pending", text: @email_address)
end
