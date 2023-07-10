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
  click_link using_design_system? ? "Create new account" : "Add"
  select social_service, from: "Service"
  fill_in using_design_system? ? "URL (required)" : "Url", with: url
  click_on "Save"
end

When(/^I add a "([^"]*)" social media link "([^"]*)" with the title "([^"]+)" to the (worldwide organisation|organisation)$/) do |social_service, url, title, social_container|
  if social_container == "worldwide organisation"
    visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  else
    visit admin_organisation_path(Organisation.last)
  end
  click_link "Social media accounts"
  click_link using_design_system? ? "Create new account" : "Add"
  select social_service, from: "Service"
  fill_in using_design_system? ? "URL (required)" : "Url", with: url
  fill_in "Title", with: title
  click_on "Save"
end

When(/^I edit a "([^"]*)" social media link "([^"]*)" with the title "([^"]+)" for the locale "([^"]*)" for the (worldwide organisation|organisation)$/) do |_social_service, url, title, locale, social_container|
  if social_container == "worldwide organisation"
    visit admin_worldwide_organisation_path(WorldwideOrganisation.last)
  else
    visit admin_organisation_path(Organisation.last)
  end
  click_link "Social media accounts"

  locale = Locale.new(locale)

  if using_design_system?
    click_link "Edit #{locale.english_language_name}"
    fill_in "URL (required)", with: url
  else
    click_link "Edit #{locale.native_and_english_language_name}"
    fill_in "Url", with: url
  end

  fill_in "Title", with: title
  click_on "Save"
end

Then(/^the "([^"]*)" social link should be shown on the public website for the (worldwide organisation|organisation)$/) do |social_service, social_container|
  social_container = if social_container == "worldwide organisation"
                       WorldwideOrganisation.last
                     else
                       Organisation.last
                     end
  visit social_container.public_path
  expect(page).to have_selector(".gem-c-share-links .gem-c-share-links__link[data-track-action=\"#{social_service.parameterize}\"]", text: social_service)
end

Then(/^the "([^"]*)" social link called "([^"]+)" should be shown on the public website for the (worldwide organisation|organisation)$/) do |social_service, title, social_container|
  social_container = if social_container == "worldwide organisation"
                       WorldwideOrganisation.last
                     else
                       Organisation.last
                     end
  visit social_container.public_path
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
