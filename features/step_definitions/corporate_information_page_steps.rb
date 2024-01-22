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

When(/^I create a new draft of the "([^"]*)" corporate information page for the worldwide organisation "([^"]*)"$/) do |page_type, org_name|
  organisation = EditionableWorldwideOrganisation.find_by(title: org_name)
  info_page = organisation.corporate_information_pages.last
  stub_publishing_api_links_with_taxons(info_page.content_id, %w[a-taxon-content-id])
  visit admin_editionable_worldwide_organisation_path(organisation)
  click_link page_type
  click_button "Create new edition"
end

When(/^I add a "([^"]*)" corporate information page to the editionable worldwide organisation$/) do |page_type|
  worldwide_organisation = EditionableWorldwideOrganisation.last
  visit admin_editionable_worldwide_organisation_path(worldwide_organisation)
  click_link "Add corporate information page"
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

When(/^I force-publish the "([^"]*)" corporate information page for the editionable worldwide organisation "([^"]*)"$/) do |page_type, org_name|
  organisation = EditionableWorldwideOrganisation.find_by(title: org_name)
  info_page = organisation.corporate_information_pages.last
  stub_publishing_api_links_with_taxons(info_page.content_id, %w[a-taxon-content-id])
  visit admin_editionable_worldwide_organisation_path(organisation)
  click_link page_type
  publish(force: true)
end

When(/^I delete the draft "([^"]*)" corporate information page for the editionable worldwide organisation "([^"]*)"$/) do |page_type, org_name|
  organisation = EditionableWorldwideOrganisation.find_by(title: org_name)
  info_page = organisation.corporate_information_pages.last
  stub_publishing_api_links_with_taxons(info_page.content_id, %w[a-taxon-content-id])
  visit admin_editionable_worldwide_organisation_path(organisation)

  click_link page_type

  click_link "Delete draft"
  click_button "Delete"

  expect(page).to have_current_path(admin_editionable_worldwide_organisation_path(organisation))
  expect(page).to have_content("The document '#{page_type}' has been deleted")
end

Then(/^I should not see the editionable worldwide organisation "([^"]*)" in the list of "([^"]*)" documents/) do |title, state|
  visit admin_editions_path(state:)

  expect(page).to_not have_content title
end

Then(/^I should see the corporate information page "([^"]*)" in the list of "([^"]*)" documents/) do |title, state|
  visit admin_editions_path(state:)

  expect(find(".govuk-table")).to have_content title
end

Then(/^I should not see the corporate information page "([^"]*)" in the list of "([^"]*)" documents/) do |title, state|
  visit admin_editions_path(state:)

  expect(page).to_not have_content title
end

Then(/^I should see the corporate information on the worldwide organisation corporate information pages page/) do
  worldwide_organisation = WorldwideOrganisation.last
  visit admin_worldwide_organisation_corporate_information_pages_path(worldwide_organisation)

  corporate_information_page = worldwide_organisation.corporate_information_pages.last

  expect(page).to have_content(corporate_information_page.title)

  click_link corporate_information_page.title
  expect(page).to have_content(corporate_information_page.title)
end

Then(/^I should see the corporate information on the editionable worldwide organisation document page/) do
  worldwide_organisation = EditionableWorldwideOrganisation.last
  visit admin_editionable_worldwide_organisation_path(worldwide_organisation)

  corporate_information_page = worldwide_organisation.corporate_information_pages.last
  expect(page).to have_content(corporate_information_page.title)

  click_link corporate_information_page.title
  expect(page).to have_content(corporate_information_page.title)
end

Then(/^I should not see the worldwide corporate information page "([^"]*)"/) do |page_title|
  expect(page).to_not have_content(page_title)
  expect(CorporateInformationPage.count).to be 0
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
