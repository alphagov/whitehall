Given(/^a closed call for evidence exists$/) do
  create(:closed_call_for_evidence)
end

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

When(/^I add an outcome to the call for evidence$/) do
  visit edit_admin_call_for_evidence_path(CallForEvidence.last)
  click_button "Create new edition"
  click_link "Outcome"

  fill_in "Summary (required)", with: "Outcome summary"
  click_button "Save"

  upload_new_attachment(pdf_attachment, "Outcome attachment title")
end

When(/^I save and publish the amended call for evidence$/) do
  call_for_evidence = CallForEvidence.last
  stub_publishing_api_links_with_taxons(call_for_evidence.content_id, %w[a-taxon-content-id])
  ensure_path edit_admin_call_for_evidence_path(call_for_evidence)
  fill_in_change_note_if_required
  apply_to_all_nations_if_required
  click_button "Save and continue"
  click_button "Update tags"
  publish force: true
end

Then(/^I can see that the call for evidence has been published$/) do
  expected_title = CallForEvidence.last.title
  expected_message = "The document #{expected_title} has been published"

  expect(page).to have_selector(".gem-c-success-alert", text: expected_message)
end
