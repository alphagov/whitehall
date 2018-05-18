When(/^I draft a new publication "([^"]*)" about the world location "([^"]*)"$/) do |title, location_name|
  begin_drafting_publication(title)
  select location_name, from: "Select the world locations this publication is about"
  click_button "Next"
  click_button "Save legacy associations"
  add_external_attachment
end

Then(/^the publication should be about the "([^"]*)" world location$/) do |location_name|
  @new_edition = Publication.last

  locations = @new_edition.world_locations

  assert_equal 1, locations.count
  assert_equal location_name, locations.first.name
end
