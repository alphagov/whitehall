When /^I draft a new international priority "([^"]*)"$/ do |title|
  begin_drafting_document type: "international_priority", title: title
  click_button "Save"
end

Given /^a published international priority "([^"]*)" exists relating to the (?:country|overseas territory|international delegation) "([^"]*)"$/ do |title, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  create(:published_international_priority, title: title, world_locations: [world_location])
end
