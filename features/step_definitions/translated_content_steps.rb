# encoding: utf-8

Given /^I am viewing a world location that is translated$/ do
  world_location = create(:world_location, translated_into: [:fr])
  worldwide_organisation = create(:worldwide_organisation,
    world_locations: [world_location],
    name: "en-organisation", summary: "en-summary",
    translated_into: {fr: {name: "fr-organisation", summary: "fr-summary"}}
  )
  visit world_location_path(world_location)
  click_link "Français"
end

When /^I visit a world organisation associated with that locale that is also translated$/ do
  click_link "fr-organisation"
end

Then /^I should see the translation of that world organisation$/ do
  assert page.has_css?(".summary", text: "fr-summary"), "expected to see the french summary, but didn't"
end
