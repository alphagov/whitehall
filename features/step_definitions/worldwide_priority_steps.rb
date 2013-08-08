# encoding: utf-8

When /^I draft a new worldwide priority "([^"]*)"$/ do |title|
  begin_drafting_document type: "worldwide_priority", title: title
  click_button "Save"
end

Given /^a published worldwide priority "([^"]*)" exists$/ do |title|
  create(:published_worldwide_priority, title: title)
end

Given /^a published worldwide priority "([^"]*)" exists relating to the (?:world location|international delegation) "([^"]*)"$/ do |title, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  create(:published_worldwide_priority, title: title, world_locations: [world_location])
end

Given /^a published worldwide priority "([^"]*)" exists relating to the worldwide organisation "([^"]*)"$/ do |title, worldwide_organisation_name|
  worldwide_organisation = WorldwideOrganisation.find_by_name!(worldwide_organisation_name)
  create(:published_worldwide_priority, title: title, worldwide_organisations: [worldwide_organisation])
end

Given /^a worldwide priority which is available in english as "([^"]*)" and in spanish as "([^"]*)"$/ do |english_title, spanish_title|
  priority = create(:draft_worldwide_priority, title: english_title)
  with_locale(:es) do
    priority.update_attributes!(attributes_for(:draft_worldwide_priority, title: spanish_title))
  end
  priority.publish_as(create(:gds_editor), force: true)
end

When /^I view the worldwide priority "([^"]*)"$/ do |title|
  priority = WorldwidePriority.find_by_title!(title)
  visit document_path(priority)
end

Then /^I should be able to navigate to the spanish translation "([^"]*)"$/ do |spanish_title|
  click_link "Español"
  assert page.has_css?('h1', text: spanish_title)
end

Then /^I should be able to navigate to the english translation "([^"]*)"$/ do |english_title|
  click_link "English"
  assert page.has_css?('h1', text: english_title)
end

When /^I visit the activity of the published priority "([^"]*)"$/ do |title|
  priority = WorldwidePriority.find_by_title!(title)
  visit activity_worldwide_priority_path(priority.document)
end

Given /^a published (publication|consultation|news article|speech) "([^"]*)" related to the priority "([^"]*)"$/ do |document_type, document_title, title|
  priority = WorldwidePriority.find_by_title!(title)
  create("published_#{document_class(document_type).name.underscore}".to_sym,
          title: document_title, related_editions: [priority])
end
