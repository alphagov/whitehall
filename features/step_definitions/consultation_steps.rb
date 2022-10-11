Given(/^a closed consultation exists$/) do
  create(:closed_consultation)
end

Given(/^an unopened consultation exists$/) do
  create(:unopened_consultation)
end

When(/^I draft a new "(.*?)" language consultation "(.*?)"$/) do |locale, title|
  document_options = { type: "consultation", title:, summary: "consultation-summary", alternative_format_provider: create(:alternative_format_provider), all_nation_applicablity: false }
  document_options.merge!(locale:) unless locale == "English"
  begin_drafting_document document_options
  fill_in "Link URL", with: "http://participate.com"
  fill_in "Email", with: "participate@gov.uk"
  select_date 1.day.ago.to_s, from: "Opening Date"
  select_date 6.days.from_now.to_s, from: "Closing Date"

  within record_css_selector(Nation.find_by_name!("Wales")) do
    check "Wales"
    fill_in "URL of corresponding content", with: "http://www.visitwales.co.uk/"
  end
  check "Scotland"
  click_button "Save"
end

Then(/^I can see links to the consultations "([^"]*)" and "([^"]*)"$/) do |title1, title2|
  expect(page).to have_selector(".consultation a", text: title1)
  expect(page).to have_selector(".consultation a", text: title2)
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
  consultation = Consultation.last
  stub_publishing_api_links_with_taxons(consultation.content_id, %w[a-taxon-content-id])
  ensure_path edit_admin_consultation_path(consultation)
  fill_in_change_note_if_required
  apply_to_all_nations_if_required
  click_button "Save"
  publish force: true
end

When(/^I mark the consultation as offsite$/) do
  check "This consultation is held on another website"
end

Then(/^the consultation can be associated with topical events$/) do
  expect(page).to have_selector("label", text: "Topical events")
end

Then(/^I can see that the consultation has been published$/) do
  expected_title = Consultation.last.title
  expected_message = "The document #{expected_title} has been published"

  expect(page).to have_selector(".flash", text: expected_message)
end

And(/^I can see the primary locale for consultation "(.*?)" is "(.*?)"$/) do |title, locale_code|
  I18n.with_locale(locale_code) do
    consultation = Consultation.find_by!(title:)
    expect(locale_code).to eq(consultation.primary_locale)
  end
end
