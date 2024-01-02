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
  expect(@worldwide_organisation.logo_formatted_name).to eq("Logo\r\nformatted\r\nname\r\n")
end

And(/^I should see it has been assigned to the "([^"]*)" world location$/) do |title|
  expect(@worldwide_organisation.world_locations.first.name).to eq(title)
end

Given(/^a role "([^"]*)" exists$/) do |name|
  create(:role, name:)
end

And(/^I edit the worldwide organisation "([^"]*)" adding the role of "([^"]*)"$/) do |title, role|
  begin_editing_document(title)
  select role, from: "Roles"
  click_button "Save and go to document summary"
end

Then(/^I should see the "([^"]*)" role has been assigned to the worldwide organisation "([^"]*)"$/) do |role, title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(@worldwide_organisation.roles.first.name).to eq(role)
end

Given(/^a social media service "([^"]*)" exists$/) do |name|
  create(:social_media_service, name:)
end

And(/^I edit the worldwide organisation "([^"]*)" adding the social media service of "([^"]*)" with title "([^"]*)" at URL "([^"]*)"$/) do |title, social_media_service_name, social_media_title, social_media_url|
  begin_editing_document(title)
  click_link "Social media accounts"
  click_link "Add new social media account"
  select social_media_service_name, from: "Service (required)"
  fill_in "URL (required)", with: social_media_url
  fill_in "Title", with: social_media_title
  click_button "Save"
end

And(/^I edit the worldwide organisation "([^"]*)" changing the social media account with title "([^"]*)" to "([^"]*)"$/) do |title, _old_social_media_title, new_social_media_title|
  begin_editing_document(title)
  click_link "Social media accounts"
  click_link "Edit"
  fill_in "Title", with: new_social_media_title
  click_button "Save"
end

And(/^I edit the worldwide organisation "([^"]*)" deleting the social media account with title "([^"]*)"$/) do |title, _social_media_title|
  begin_editing_document(title)
  click_link "Social media accounts"
  click_link "Delete"
  click_button "Delete"
end

Then(/^I should see the "([^"]*)" social media site has been assigned to the worldwide organisation "([^"]*)"$/) do |social_media_title, title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(@worldwide_organisation.social_media_accounts.first.title).to eq(social_media_title)
end

Then(/^I should see the worldwide organisation "([^"]*)" has no social media accounts$/) do |title|
  @worldwide_organisation = EditionableWorldwideOrganisation.find_by(title:)
  expect(@worldwide_organisation.social_media_accounts).to be_empty
end
