When /^I draft a new consultation "([^"]*)"$/ do |title|
  policy = create(:policy)
  begin_drafting_document type: 'consultation', title: title, summary: 'consultation-summary', alternative_format_provider: create(:alternative_format_provider)
  fill_in "Link URL", with: "http://participate.com"
  fill_in "Email", with: "participate@gov.uk"
  select_date "Opening Date", with: 1.day.ago.to_s
  select_date "Closing Date", with: 6.days.from_now.to_s
  add_attachment "Attachment Title", "attachment.pdf", "#edition_attachment_fields"
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
end

When /^I save and publish the amended consultation$/ do
  click_button "Save"
  click_button "Force Publish"
end

Then /^the consultation response should be viewable$/ do
  select_most_recent_consultation_from_list
  view_visible_consultation_on_website
  should_have_consultation_response_attachment
end

When /^I specify the published response date of the consultation$/ do
  select_date "Response published date", with: 1.day.ago.strftime("%Y-%m-%d")
end

Then /^the published date should be visible on save$/ do
  date = 1.day.ago.strftime("%Y-%m-%d")
  click_button "Save"
  page.should have_css("abbr.published_on_or_default", title: date)
  click_button "Force Publish"

  select_most_recent_consultation_from_list
  view_visible_consultation_on_website
  should_have_consultation_response_attachment_with_published_date(date)
end
