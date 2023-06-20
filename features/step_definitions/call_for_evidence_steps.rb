When(/^I draft a new call for evidence "(.*?)"$/) do |title|
  document_options = { type: "call_for_evidence", title:, summary: "call-for-evidence-summary", alternative_format_provider: create(:alternative_format_provider), all_nation_applicablity: false }
  begin_drafting_document document_options
  fill_in "Link URL", with: "http://participate.com"
  fill_in "Email", with: "participate@gov.uk"

  within "#edition_opening_at" do
    fill_in_date_and_time_field(1.day.ago.to_s)
  end

  within "#edition_closing_at" do
    fill_in_date_and_time_field(6.days.from_now.to_s)
  end

  check "Does not apply to Wales"
  fill_in "edition[nation_inapplicabilities_attributes][2][alternative_url]", with: "http://www.visitwales.co.uk/"

  check "Scotland"
  click_button "Save"
end

When(/^I mark the call for evidence as offsite$/) do
  check "This call for evidence is held on another website"
end

Then(/^the call for evidence can be associated with topical events$/) do
  expect(page).to have_selector("label", text: "Topical events")
end
