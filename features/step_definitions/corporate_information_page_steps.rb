# encoding: utf-8

Given /^I add a "([^"]*)" corporate information page to "([^"]*)" with body "([^"]*)"$/ do |page_type, org_name, body|
  organisation = Organisation.find_by_name(org_name)
  visit admin_organisation_path(organisation)
  click_link "Corporate information pages"
  click_link "New corporate information page"
  fill_in "Body", with: body
  select page_type, from: "Type"
  click_button "Save"
end

When /^I click the "([^"]*)" link$/ do |link_text|
  click_link link_text
end

Then /^I should see the text "([^"]*)"$/ do |text|
  assert has_css?("body", text: Regexp.new(Regexp.escape(text)))
end

When /^I add a "([^"]*)" corporate information page to the worldwide organisation$/ do |page_type|
  worldwide_organisation = WorldwideOrganisation.last
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link "Corporate information pages"
  click_link "New corporate information page"
  fill_in "Body", with: "This is a new #{page_type} page"
  select page_type, from: "Type"
  click_button "Save"
end

Then /^I should see the corporate information on the public worldwide organisation page$/ do
  worldwide_organisation = WorldwideOrganisation.last
  info_page = worldwide_organisation.corporate_information_pages.last
  visit worldwide_organisation_path(worldwide_organisation)
  assert page.has_content?(info_page.title)
  click_link info_page.title
  assert page.has_content?(info_page.body)
end

When /^I translate the "([^"]*)" corporate information page for the worldwide organisation "([^"]*)"$/ do |corp_page, worldwide_org|
  worldwide_organisation = WorldwideOrganisation.find_by_name(worldwide_org)
  visit admin_worldwide_organisation_path(worldwide_organisation)
  click_link "Corporate information pages"
  corporate_information_page_type = CorporateInformationPageType.find_by_title(corp_page)
  corporate_information_page = worldwide_organisation.corporate_information_pages.by_type(corporate_information_page_type).first

  within(record_css_selector(corporate_information_page)) do
    click_link "Manage translations"
  end

  select "Français", from: "Locale"
  click_on "Create translation"
  fill_in "Summary", with: "Le summary"
  fill_in "Body", with: "Le body"
  click_on "Save"
end

Then /^I should be able to read the translated "([^"]*)" corporate information page for the worldwide organisation "([^"]*)" on the site$/ do |corp_page, worldwide_org|
  worldwide_organisation = WorldwideOrganisation.find_by_name(worldwide_org)
  visit worldwide_organisation_path(worldwide_organisation)

  click_link corp_page
  click_link "Français"

  assert page.has_css?(".description", text: "Le summary")
  assert page.has_css?(".body", text: "Le body")
end
