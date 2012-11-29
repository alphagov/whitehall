When /^I create a fatality notice titled "([^"]*)" in the field "([^"]*)"$/ do |title, field|
  begin_drafting_document type: "fatality_notice", title: title
  fill_in "Body", with: "fatality notice summary"
  select field, from: "Field of operations"
  click_button "Save"
  click_button "Force Publish"
end
