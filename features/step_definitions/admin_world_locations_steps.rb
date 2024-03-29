When(/^I draft a new publication "([^"]*)" about the world location "([^"]*)"$/) do |title, location_name|
  begin_drafting_publication(title)
  select location_name, from: "World locations"
  click_button "Save and go to document summary"
  add_external_attachment
end

Then(/^the publication should be about the "([^"]*)" world location$/) do |location_name|
  @new_edition = Publication.last

  locations = @new_edition.world_locations

  expect(1).to eq(locations.count)
  expect(location_name).to eq(locations.first.name)
end
