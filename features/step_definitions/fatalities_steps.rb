When /^I create a fatality notice titled "([^"]*)" in the field "([^"]*)"$/ do |title, field|
  create(:operational_field, name: field)
  begin_drafting_document type: "fatality_notice", title: title
  fill_in "Summary", with: "fatality notice summary"
  select field, from: "Field of operation"
  click_button "Save"
  click_button "Force Publish"
end

Then /^the fatality notice should be visible on the public site$/ do
  visit homepage
  click_link "Announcements"
  assert page.has_content?(FatalityNotice.last.title)
end

Then /^the document should be clearly marked as a fatality notice$/ do
  click_link FatalityNotice.last.title
  assert page.has_css?(".label", text: "Fatality")
end

Then /^the document should show the field of operation as "([^"]*)"$/ do |field|
  assert page.has_css?("dt", text: "Field of operation:")
  assert page.has_css?("dd", text: field)
end
