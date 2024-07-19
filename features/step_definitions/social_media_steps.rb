Given(/^a social media service "([^"]*)"$/) do |name|
  create(:social_media_service, name:)
end

When(/^I add a "([^"]*)" social media link "([^"]*)" to the (worldwide organisation|organisation)$/) do |social_service, url, social_container|
  if social_container == "worldwide organisation"
    visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  else
    visit admin_organisation_path(Organisation.last)
  end
  click_link "Social media accounts"
  click_link "Create new account"
  select social_service, from: "Service"
  fill_in "URL (required)", with: url
  click_on "Save"
end

When(/^I add a "([^"]*)" social media link "([^"]*)" with the title "([^"]+)" to the (worldwide organisation|organisation)$/) do |social_service, url, title, social_container|
  if social_container == "worldwide organisation"
    visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  else
    visit admin_organisation_path(Organisation.last)
  end
  click_link "Social media accounts"
  click_link "Create new account"
  select social_service, from: "Service"
  fill_in "URL (required)", with: url
  fill_in "Title", with: title
  click_on "Save"
end

Then(/^I should be able to see the "([^"]*)" social service for the worldwide organisation$/) do |social_service|
  visit admin_worldwide_organisation_social_media_accounts_path(WorldwideOrganisation.last)
  expect(page).to have_content(social_service)
end

Then(/^the social link called "([^"]*)" should be shown on the edit page for "([^"]*)"$/) do |name, language|
  visit admin_worldwide_organisation_social_media_accounts_path(WorldwideOrganisation.last)
  click_link "Edit #{language}"
  expect(page).to have_field("Title", with: name)
end
