# encoding: utf-8

Given(/^I visit the role page for "(.*?)"$/) do |name|
  role = Role.find_by_name(name)
  visit polymorphic_path(role)
end

Given(/^I visit the people page for "(.*?)"$/) do |name|
  person = Person.find_by_name(name)
  visit polymorphic_path(person)
end

Given /^a person called "([^"]*)" is assigned as its ambassador "([^"]*)"$/ do |person_name, role_name|
  person = create_person(person_name)
  role = create(:ambassador_role, name: role_name, worldwide_organisations: [WorldwideOrganisation.last])
  role_appointment = create(:ambassador_role_appointment, role: role, person: person)
end

Given /^an ambassador role named "([^"]*)" in the "([^"]*)" worldwide organisation$/ do |role_name, worldwide_organisation_name|
  worldwide_organisation = WorldwideOrganisation.find_by_name!(worldwide_organisation_name)
  create(:ambassador_role, name: role_name, worldwide_organisations: [worldwide_organisation])
end

Given /^a person called "([^"]*)" appointed as "([^"]*)" with a biography in "([^"]*)"$/ do |person_name, role_name, language_name|
  locale = Locale.find_by_language_name(language_name)
  person = create_person(person_name, translated_into: {
    en: { biography: "english-biography" },
    locale.code => { biography: "#{locale}-biography" }
  })
  role = Role.find_by_name!(role_name)
  create(:ambassador_role_appointment, role: role, person: person)
end

When /^I add a new "([^"]*)" role named "([^"]*)" to the "([^"]*)"$/ do |role_type, role_name, organisation_name|
  @role_name = role_name

  visit admin_roles_path
  click_on "Create role"
  fill_in "Role title", with: role_name
  select role_type, from: "Type"
  select organisation_name, from: "Organisations"
  click_on "Save"
end

When /^I add a new "([^"]*)" role named "([^"]*)" to the "([^"]*)" worldwide organisation$/ do |role_type, role_name, worldwide_organisation_name|
  visit admin_roles_path
  click_on "Create role"
  fill_in "Role title", with: role_name
  select role_type, from: "Type"
  select worldwide_organisation_name, from: "Worldwide organisations"
  click_on "Save"
end

When /^I add a new "([^"]*)" translation to the role "([^"]*)" with:$/ do |locale_name, role_name, table|
  role = Role.find_by_name!(role_name)
  translation = table.rows_hash.stringify_keys
  locale = Locale.find_by_language_name(locale_name)

  visit admin_roles_path
  within record_css_selector(role) do
    click_link "Manage translations"
  end

  select locale.native_and_english_language_name, from: "Locale"
  click_on "Create translation"
  fill_in "Name", with: translation["name"]
  fill_in "Responsibilities", with: translation["responsibilities"]
  click_on "Save"
end

Then /^I should be able to appoint "([^"]*)" to the new role$/ do |person_name|
  role = Role.last
  click_on role.name
  click_on "New appointment"
  select person_name, from: "Person"
  select_date 1.day.ago.to_s, from: "Started at"
  click_on "Save"
end

Then /^I should see "([^"]*)" listed on the "([^"]*)" organisation page$/ do |person_name, organisation_name|
  visit_organisation organisation_name
  role = find_person(person_name).roles.first
  assert page.has_css?(record_css_selector(role.current_person))
end

Then /^I should see him listed as "([^"]*)" on the worldwide organisation page$/ do |role_name|
  visit worldwide_organisation_path(WorldwideOrganisation.last)
  person = Person.last
  role = Role.find_by_name!(role_name)

  within record_css_selector(person) do
    assert page.has_content?(person.name)
    assert page.has_content?(role.name)
  end
end

Given(/^a role named "(.*?)" in the "(.*?)" organisation exists$/) do |role_name, organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  create(:role, name: role_name, people: [], organisations: [organisation])
end

When(/^I mark that role as inactive$/) do
  role = Role.last
  visit admin_roles_path
  click_on role.name
  select "No longer exists", from: "status"
  click_on "Save"
end

Then(/^I should see an inactive role banner on the role page$/) do
  role = Role.last
  visit polymorphic_path(role)
  assert page.has_content?("#{role.name} no longer exists")
end

When(/^I mark the role "(.*?)" as replaced by "(.*?)"$/) do |role_name, replacement_role_name|
  role = Role.find_by_name(role_name)
  replacement_role = Role.find_by_name(replacement_role_name)
  visit admin_roles_path
  click_on role.name
  select "Replaced", from: "status"
  select "#{replacement_role.name}", from: "role_superseding_role_ids"
  click_on "Save"
end

Then(/^I should see a replaced role banner on the "(.*?)" role page$/) do |role_name|
  role = Role.find_by_name(role_name)
  replacement_role = role.superseding_roles.first
  visit polymorphic_path(role)
  assert page.has_content?("#{role.name} was replaced by <a href=\"#{polymorphic_path(replacement_role)}\">#{replacement_role.name}</a>")
end
