When /^I draft a new consultation "([^"]*)"$/ do |title|
  policy = create(:policy)
  begin_drafting_document type: 'consultation', title: title, alternative_format_provider: create(:alternative_format_provider)
  fill_in "Summary", with: "consultation-summary"
  fill_in "Link URL", with: "http://participate.com"
  fill_in "Email", with: "participate@gov.uk"
  select_date "Opening Date", with: 1.day.ago.to_s
  select_date "Closing Date", with: 6.days.from_now.to_s
  add_attachment "Attachment Title", "attachment.pdf", ".attachments"
  check "Wales"
  fill_in "Alternative url", with: "http://www.visitwales.co.uk/"
  check "Scotland"
  select policy.title, from: "Related policies"
  click_button "Save"
end

Then /^I can see links to the consultations "([^"]*)" and "([^"]*)"$/ do |title_1, title_2|
  assert has_css?(".consultation a", text: title_1)
  assert has_css?(".consultation a", text: title_2)
end

When /^I add a response to the consultation$/ do
  visit edit_admin_consultation_path(Consultation.last)
  click_button "Create new edition"
  add_attachment("Response Title", "attachment.pdf", "#consultation_response_attachment_fields")
  select_date "Opening Date", with: 2.days.ago.strftime("%Y-%m-%d")
  select_date "Closing Date", with: 1.day.ago.strftime("%Y-%m-%d")

  fill_in_change_note_if_required
  click_button "Save"
end

When /^I publish the amended consultation$/ do
  click_button "Force Publish"
end

Then /^the consultation response should be viewable$/ do
  click_link(Consultation.last.title)
  click_link(Consultation.last.title)
  page.should have_css(".consultation-responded .attachment", :count => 1)
end
