And(/^a topical event called "([^"]*)" exists$/) do |name|
  @topical_event = create(:topical_event, name:)
end

Given(/^the topical event has an offsite link with the title "([^"]*)"$/) do |title|
  create(:offsite_link, parent_type: "TopicalEvent", parent: @topical_event, title:)
end

When(/^I visit the topical event featuring index page$/) do
  visit admin_topical_event_topical_event_featurings_path(@topical_event)
end
