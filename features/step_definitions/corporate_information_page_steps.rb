def find_corporation_information_page_type_by_title(title)
  I18n.with_locale(:en) do
    CorporateInformationPageType.all.detect { |type| type.title(Organisation.new) == title }
  end
end

Then(/^I should see the text "([^"]*)"$/) do |text|
  expect(page).to have_content(text, normalize_ws: true)
end

When(/^I add a "([^"]*)" corporate information page to the worldwide organisation$/) do |page_type|
  worldwide_organisation = WorldwideOrganisation.last
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link "Pages"
  click_link "Create new corporate information page"
  fill_in "Body", with: "This is a new #{page_type} page"
  select page_type, from: "Type"
  click_button "Save"
end

When(/^I force-publish the "([^"]*)" corporate information page for the worldwide organisation "([^"]*)"$/) do |page_type, org_name|
  organisation = WorldwideOrganisation.find_by(name: org_name)
  info_page = organisation.corporate_information_pages.last
  stub_publishing_api_links_with_taxons(info_page.content_id, %w[a-taxon-content-id])
  visit admin_worldwide_organisation_path(organisation)
  click_link "Pages"
  click_link page_type
  publish(force: true)
end

When(/^I unpublish the "([^"]*)" corporate information page for the worldwide organisation "([^"]*)"$/) do |cip_title, org_name|
  edition = WorldwideOrganisation.find_by(name: org_name).corporate_information_pages.find_by(title: cip_title)
  unpublish_edition(edition) do
    fill_in "published_in_error_alternative_url", with: "https://www.gov.uk/somewhere-else"
    check "Redirect to URL automatically?"
  end
end

Then(/^I should see the corporate information on the worldwide organisation corporate information pages page/) do
  worldwide_organisation = WorldwideOrganisation.last
  visit admin_worldwide_organisation_corporate_information_pages_path(worldwide_organisation)

  corporate_information_page = worldwide_organisation.corporate_information_pages.last

  expect(page).to have_content(corporate_information_page.title)

  click_link corporate_information_page.title
  expect(page).to have_content(corporate_information_page.title)
end

Then(/^I should not see the corporate information page "([^"]*)" on the worldwide organisation corporate information pages page/) do |cip_title|
  worldwide_organisation = WorldwideOrganisation.last
  visit admin_worldwide_organisation_corporate_information_pages_path(worldwide_organisation)

  expect(page).to_not have_content(cip_title)
end

When(/^I translate the "([^"]*)" corporate information page for the worldwide organisation "([^"]*)"$/) do |corp_page, worldwide_org|
  worldwide_organisation = WorldwideOrganisation.find_by(name: worldwide_org)
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link "Pages"
  click_link corp_page
  click_link "Add translation"

  select "Français", from: "Choose language"
  click_button "Next"
  fill_in "Translated summary", with: "Le summary"
  fill_in "Translated body (required)", with: "Le body"
  click_on "Save"
end

Then(/^I should be able to see the "([^"]*)" translation for the corporate information page of the worldwide organisation "([^"]*)"$/) do |language, worldwide_org|
  worldwide_organisation = WorldwideOrganisation.find_by(name: worldwide_org)
  corporate_information_page = worldwide_organisation.corporate_information_pages.last
  visit admin_worldwide_organisation_corporate_information_page_path(worldwide_organisation, corporate_information_page)

  expect(page).to have_content("Translations")

  within(".govuk-table") do
    expect(page).to have_content(language)
  end
end
