Given(/^The editionable worldwide organisations feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:editionable_worldwide_organisations, enabled == "enabled")
end

When(/^I draft a new worldwide organisation "([^"]*)" assigned to world location "([^"]*)"$/) do |title, world_location|
  begin_drafting_worldwide_organisation(title:, world_location:)
  click_button "Save and go to document summary"
end

Then(/^the worldwide organisation "([^"]*)" should have been created$/) do |title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(@worldwide_organisation).to be_present
end

And(/^I should see it has been assigned to the "([^"]*)" world location$/) do |title|
  expect(@worldwide_organisation.world_locations.first.name).to eq(title)
end
