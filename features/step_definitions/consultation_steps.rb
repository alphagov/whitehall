When /^I draft a new consultation "([^"]*)"$/ do |title|
  policy = create(:policy)
  begin_drafting_document type: 'consultation', title: title
  fill_in "Summary", with: "consultation-summary"
  select_date "Opening Date", with: 1.day.ago.to_s
  select_date "Closing Date", with: 6.days.from_now.to_s
  within ".attachments" do
    fill_in "Title", with: "Attachment Title"
    attach_file "File", Rails.root.join("features/fixtures/attachment.pdf")
  end
  check "Wales"
  fill_in "Alternative url", with: "http://www.visitwales.co.uk/"
  check "Scotland"
  select policy.title, from: "Related policies"
  click_button "Save"
end

When /^I visit the consultations page$/ do
  visit consultations_path
end

Then /^I can see links to the consultations "([^"]*)" and "([^"]*)"$/ do |title_1, title_2|
  assert has_css?(".consultation a", text: title_1)
  assert has_css?(".consultation a", text: title_2)
end
