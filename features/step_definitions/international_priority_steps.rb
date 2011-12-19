When /^I draft a new international priority "([^"]*)"$/ do |title|
  begin_drafting_document type: "international_priority", title: title
  click_button "Save"
end
