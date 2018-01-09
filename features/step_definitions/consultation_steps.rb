Given(/^a closed consultation exists$/) do
  create(:closed_consultation)
end

Given(/^an unopened consultation exists$/) do
  create(:unopened_consultation)
end

When(/^I draft a new consultation "([^"]*)"$/) do |title|
  publishing_api_has_policies([title])

  begin_drafting_document type: 'consultation', title: title, summary: 'consultation-summary', alternative_format_provider: create(:alternative_format_provider)
  fill_in "Link URL", with: "http://participate.com"
  fill_in "Email", with: "participate@gov.uk"
  select_date 1.day.ago.to_s, from: "Opening Date"
  select_date 6.days.from_now.to_s, from: "Closing Date"

  within record_css_selector(Nation.find_by_name!("Wales")) do
    check "Wales"
    fill_in "Alternative url", with: "http://www.visitwales.co.uk/"
  end
  check "Scotland"
  select title, from: "Policies"
  click_button "Save"
end

Then(/^I can see links to the consultations "([^"]*)" and "([^"]*)"$/) do |title_1, title_2|
  assert has_css?(".consultation a", text: title_1)
  assert has_css?(".consultation a", text: title_2)
end

When(/^I add an outcome to the consultation$/) do
  visit edit_admin_consultation_path(Consultation.last)
  click_button "Create new edition"

  click_link "Final outcome"
  fill_in "Detail/Summary", with: "Outcome summary"
  click_button "Save"

  upload_new_attachment(pdf_attachment, "Outcome attachment title")
end

When(/^I add public feedback to the consultation$/) do
  visit edit_admin_consultation_path(Consultation.last)
  click_button "Create new edition"

  click_link "Public feedback"
  fill_in "Summary", with: "Feedback summary"
  click_button "Save"

  upload_new_attachment(pdf_attachment, "Feedback attachment title")
end

When(/^I save and publish the amended consultation$/) do
  ensure_path edit_admin_consultation_path(Consultation.last)
  fill_in_change_note_if_required
  click_button "Save"
  publish force: true
end

When(/^I mark the consultation as offsite$/) do
  check 'This consultation is held on another website'
end

Then(/^the consultation can be associated with topical events$/) do
  assert has_css?('label', text: 'Topical events')
end

Then(/^I can see that the consultation has been published$/) do
  expected_title = Consultation.last.title
  expected_message = "The document #{expected_title} has been published"

  assert has_css?('.flash', text: expected_message)
end
