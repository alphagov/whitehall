When /^I draft a new specialist guide "([^"]*)"$/ do |title|
  begin_drafting_document type: 'specialist_guide', title: title
  click_button "Save"
end

When /^I draft a new specialist guide "([^"]*)" in the "([^"]*)" and "([^"]*)" topics$/ do |title, first_topic, second_topic|
  begin_drafting_document type: 'specialist_guide', title: title
  select first_topic, from: "Topics"
  select second_topic, from: "Topics"
  click_button "Save"
end
