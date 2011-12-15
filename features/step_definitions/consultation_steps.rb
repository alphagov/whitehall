Given /^a published featured consultation "([^"]*)"$/ do |title|
  create(:published_consultation, title: title, featured: true)
end

Given /^(\d+) published featured consultations$/ do |number|
  number.to_i.times { create(:published_consultation, featured: true) }
end

When /^I draft a new consultation "([^"]*)"$/ do |title|
  policy = create(:policy)
  begin_drafting_document type: 'consultation', title: title
  fill_in "Summary", with: "consultation-summary"
  select_date "Opening Date", with: 1.day.ago.to_s
  select_date "Closing Date", with: 6.days.from_now.to_s
  attach_file "Attachment", Rails.root.join("features/fixtures/attachment.pdf")
  check "Wales"
  fill_in "Alternative url", with: "http://www.visitwales.co.uk/"
  check "Scotland"
  select policy.title, from: "Related Policies"
  click_button "Save"
end

When /^I visit the consultations page$/ do
  visit consultations_path
end

Then /^I can see links to the related published consultations "([^"]*)" and "([^"]*)"$/ do |consultation_title_1, consultation_title_2|
  consultation_1 = Consultation.published.find_by_title!(consultation_title_1)
  consultation_2 = Consultation.published.find_by_title!(consultation_title_2)
  assert has_css?("#{related_consultations_selector} .consultation a", text: consultation_title_1)
  assert has_css?("#{related_consultations_selector} .consultation a", text: consultation_title_2)
end

Then /^I should see "([^"]*)" in the list of featured consultations$/ do |title|
  assert has_css?("#{featured_consultations_selector} .consultation a", text: title)
end

Then /^I should only see the most recent (\d+) in the list of featured consultations$/ do |number|
  assert has_css?("#{featured_consultations_selector} .consultation", count: number.to_i)
end