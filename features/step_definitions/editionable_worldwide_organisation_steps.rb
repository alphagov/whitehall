Given(/^The editionable worldwide organisations feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:editionable_worldwide_organisations, enabled == "enabled")
end

When(/^I draft a new worldwide organisation "([^"]*)"$/) do |title|
  begin_drafting_worldwide_organisation(title:)
  click_button "Save and go to document summary"
end

Then(/^the worldwide organisation "([^"]*)" should have been created$/) do |title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(@worldwide_organisation).to be_present
end
