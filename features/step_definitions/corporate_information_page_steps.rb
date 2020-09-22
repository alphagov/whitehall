def find_corporation_information_page_type_by_title(title)
  I18n.with_locale(:en) do
    CorporateInformationPageType.all.detect { |type| type.title(Organisation.new) == title }
  end
end

Then(/^I should see the text "([^"]*)"$/) do |text|
  assert_text text, normalize_ws: true
end

When(/^I add a "([^"]*)" corporate information page to the worldwide organisation$/) do |page_type|
  worldwide_organisation = WorldwideOrganisation.last
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link "Corporate information pages"
  click_link "New corporate information page"
  fill_in "Body", with: "This is a new #{page_type} page"
  select page_type, from: "Type"
  click_button "Save"
end

When(/^I force-publish the "([^"]*)" corporate information page for the worldwide organisation "([^"]*)"$/) do |page_type, org_name|
  organisation = WorldwideOrganisation.find_by(name: org_name)
  info_page = organisation.corporate_information_pages.last
  stub_publishing_api_links_with_taxons(info_page.content_id, %w[a-taxon-content-id])
  visit admin_worldwide_organisation_path(organisation)
  click_link "Corporate information pages"
  click_link page_type
  publish(force: true)
end

Then(/^I should see the corporate information on the public worldwide organisation page$/) do
  worldwide_organisation = WorldwideOrganisation.last
  info_page = worldwide_organisation.corporate_information_pages.last
  visit worldwide_organisation_path(worldwide_organisation)
  assert_text info_page.title
  click_link info_page.title
  assert_text info_page.body
end

When(/^I translate the "([^"]*)" corporate information page for the worldwide organisation "([^"]*)"$/) do |corp_page, worldwide_org|
  worldwide_organisation = WorldwideOrganisation.find_by(name: worldwide_org)
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link "Corporate information pages"
  click_link corp_page
  click_link "open-add-translation-modal"
  select "Français", from: "Locale"
  click_button "Add translation"
  fill_in "Summary", with: "Le summary"
  fill_in "Body", with: "Le body"
  click_on "Save"
end

Then(/^I should be able to read the translated "([^"]*)" corporate information page for the worldwide organisation "([^"]*)" on the site$/) do |corp_page, worldwide_org|
  worldwide_organisation = WorldwideOrganisation.find_by(name: worldwide_org)
  visit worldwide_organisation_path(worldwide_organisation)

  click_link corp_page
  click_link "Français"

  assert_selector ".govuk-body-l", text: "Le summary"
  assert_selector ".body", text: "Le body"
end
