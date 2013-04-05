Given /^a social media service "([^"]*)"$/ do |name|
  create(:social_media_service, name: name)
end

When /^I add a "([^"]*)" social media link "([^"]*)" to the (worldwide organisation|organisation)$/ do |social_service, url, social_container|
  if social_container == 'worldwide organisation'
    visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  else
    visit admin_organisation_path(Organisation.last)
  end
  click_link "Social media accounts"
  click_link "Add"
  select social_service, from: "Service"
  fill_in "Url", with: url
  click_on "Save"
end

Then /^the social link should be shown on the public website for the (worldwide organisation|organisation)$/ do |social_container|
  if social_container == 'worldwide organisation'
    visit worldwide_organisation_path(WorldwideOrganisation.last)
  else
    visit organisation_path(Organisation.last)
  end
  assert page.has_css?(".social-media-accounts")
end
