When /^I draft a new specialist guide "([^"]*)"$/ do |title|
  begin_drafting_document type: 'specialist_guide', title: title
  click_button "Save"
end
