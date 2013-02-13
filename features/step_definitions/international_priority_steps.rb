# encoding: utf-8

When /^I draft a new international priority "([^"]*)"$/ do |title|
  begin_drafting_document type: "international_priority", title: title
  click_button "Save"
end

Given /^a published international priority "([^"]*)" exists relating to the (?:country|overseas territory|international delegation) "([^"]*)"$/ do |title, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  create(:published_international_priority, title: title, world_locations: [world_location])
end

Given /^an international priority which is available in english as "([^"]*)" and in spanish as "([^"]*)"$/ do |english_title, spanish_title|
  priority = create(:draft_international_priority, title: english_title)
  with_locale(:es) do
    priority.update_attributes!(attributes_for(:draft_international_priority, title: spanish_title))
  end
  priority.publish_as(create(:departmental_editor), force: true)
end

When /^I view the international priority "([^"]*)"$/ do |title|
  priority = InternationalPriority.find_by_title!(title)
  visit document_path(priority)
end

Then /^I should be able to navigate to the spanish translation "([^"]*)"$/ do |spanish_title|
  click_link "Español"
  assert page.has_css?('.title', text: spanish_title)
end

Then /^I should be able to navigate to the english translation "([^"]*)"$/ do |english_title|
  click_link "English"
  assert page.has_css?('.title', text: english_title)
end
