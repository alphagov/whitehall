When /^I draft a new consultation "([^"]*)"$/ do |title|
  policy = create(:policy)
  begin_drafting_document type: 'consultation', title: title
  select_date "Opening Date", with: 1.day.ago.to_s
  select_date "Closing Date", with: 6.days.from_now.to_s
  attach_file "Attachment", Rails.root.join("features/fixtures/attachment.pdf")
  check "Wales"
  fill_in "Alternative url", with: "http://www.visitwales.co.uk/"
  check "Scotland"
  select policy.title, from: "Related Policies"
  click_button "Save"
end

Then /^I can see links to the related published consultations "([^"]*)" and "([^"]*)"$/ do |consultation_title_1, consultation_title_2|
  consultation_1 = Consultation.published.find_by_title!(consultation_title_1)
  consultation_2 = Consultation.published.find_by_title!(consultation_title_2)
  assert has_css?("#{related_consultations_selector} .consultation a", text: consultation_title_1)
  assert has_css?("#{related_consultations_selector} .consultation a", text: consultation_title_2)
end