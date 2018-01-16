Given(/^a social media service "([^"]*)"$/) do |name|
  create(:social_media_service, name: name)
end

When(/^I add a "([^"]*)" social media link "([^"]*)" to the (worldwide organisation|organisation)$/) do |social_service, url, social_container|
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

When(/^I add a "([^"]*)" social media link "([^"]*)" with the title "([^"]+)" to the (worldwide organisation|organisation)$/) do |social_service, url, title, social_container|
  if social_container == 'worldwide organisation'
    visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  else
    visit admin_organisation_path(Organisation.last)
  end
  click_link "Social media accounts"
  click_link "Add"
  select social_service, from: "Service"
  fill_in "Url", with: url
  fill_in "Title", with: title
  click_on "Save"
end

Then(/^the "([^"]*)" social link should be shown on the public website for the (worldwide organisation|organisation)$/) do |social_service, social_container|
  if social_container == 'worldwide organisation'
    social_container = WorldwideOrganisation.last
    visit worldwide_organisation_path(social_container)
  else
    social_container = Organisation.last
    visit organisation_path(social_container)
  end
  assert page.has_css?(".social-media-accounts .social-media-link.#{social_service.parameterize}", text: "Connect with #{social_container.display_name} on #{social_service}")
end

Then(/^the "([^"]*)" social link called "([^"]+)" should be shown on the public website for the (worldwide organisation|organisation)$/) do |social_service, title, social_container|
  if social_container == 'worldwide organisation'
    social_container = WorldwideOrganisation.last
    visit worldwide_organisation_path(social_container)
  else
    social_container = Organisation.last
    visit organisation_path(social_container)
  end
  assert page.has_css?(".social-media-accounts .social-media-link.#{social_service.parameterize}", text: "Connect with #{social_container.display_name} on #{title}")
end
