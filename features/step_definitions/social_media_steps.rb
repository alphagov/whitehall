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
  click_link "Add"
  select social_service, from: "Service"
  fill_in "Url", with: url
  click_on "Save"
end

When(/^I add a "([^"]*)" social media link "([^"]*)" with the title "([^"]+)" to the (worldwide organisation|organisation)$/) do |social_service, url, title, social_container|
  if social_container == "worldwide organisation"
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

When(/^I edit a "([^"]*)" social media link "([^"]*)" with the title "([^"]+)" in "([^"]*)" for the (worldwide organisation|organisation)$/) do |_social_service, url, title, language, social_container|
  if social_container == "worldwide organisation"
    visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  else
    visit admin_organisation_path(Organisation.last)
  end
  click_link "Social media accounts"
  click_link "Edit #{language}"
  fill_in "Url", with: url
  fill_in "Title", with: title
  click_on "Save"
end

Then(/^the "([^"]*)" social link should be shown on the public website for the (worldwide organisation|organisation)$/) do |social_service, social_container|
  social_container = if social_container == "worldwide organisation"
                       WorldwideOrganisation.last
                     else
                       Organisation.last
                     end
  visit social_container.public_path(locale: :en)
  expect(page).to have_selector(".gem-c-share-links .gem-c-share-links__link[data-track-action=\"#{social_service.parameterize}\"]", text: social_service)
end

Then(/^the "([^"]*)" social link called "([^"]+)" should be shown on the public website for the (worldwide organisation|organisation)$/) do |social_service, title, social_container|
  social_container = if social_container == "worldwide organisation"
                       WorldwideOrganisation.last
                     else
                       Organisation.last
                     end
  visit social_container.public_path(locale: :en)
  expect(page).to have_selector(".gem-c-share-links .gem-c-share-links__link[data-track-action=\"#{social_service.parameterize}\"]", text: title)
end

Then(/^the "([^"]*)" social link called "([^"]+)" should be shown on the public website with locale "([^"]*)" for the (worldwide organisation|organisation)$/) do |social_service, title, locale, social_container|
  social_container = if social_container == "worldwide organisation"
                       WorldwideOrganisation.last
                     else
                       Organisation.last
                     end
  visit social_container.public_path(locale:)
  expect(page).to have_selector(".gem-c-share-links .gem-c-share-links__link[data-track-action=\"#{social_service.parameterize}\"]", text: title)
end
