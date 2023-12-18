Given(/^The editionable worldwide organisations feature flag is (enabled|disabled)$/) do |enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:editionable_worldwide_organisations, enabled == "enabled")
end

When(/^I draft a new worldwide organisation "([^"]*)"$/) do |_title|
  begin_drafting_worldwide_organisation({})
  click_button "Save and go to document summary"
end
