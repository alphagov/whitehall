# encoding: utf-8

Given(/^I visit the role page for "(.*?)"$/) do |name|
  role = Role.find_by(name: name)
  visit polymorphic_path(role)
end

Given(/^an ambassador role named "([^"]*)" in the "([^"]*)" worldwide organisation$/) do |role_name, worldwide_organisation_name|
  worldwide_organisation = WorldwideOrganisation.find_by!(name: worldwide_organisation_name)
  create(:ambassador_role, name: role_name, worldwide_organisations: [worldwide_organisation])
end

Given(/^a person called "([^"]*)" appointed as "([^"]*)" with a biography in "([^"]*)"$/) do |person_name, role_name, language_name|
  locale = Locale.find_by_language_name(language_name)
  person = create_person(person_name, translated_into: {
    en: { biography: "english-biography" },
    locale.code => { biography: "#{locale}-biography" },
  })
  role = Role.find_by!(name: role_name)
  create(:ambassador_role_appointment, role: role, person: person)
end

When(/^I add a new "([^"]*)" role named "([^"]*)" to the "([^"]*)"$/) do |role_type, role_name, organisation_name|
  @role_name = role_name

  visit admin_roles_path
  click_on "Create role"
  fill_in "Role title", with: role_name
  select role_type, from: "Role type"
  select organisation_name, from: "Organisations"
  click_on "Save"
end

When(/^I add a new "([^"]*)" role named "([^"]*)" to the "([^"]*)" worldwide organisation$/) do |role_type, role_name, worldwide_organisation_name|
  visit admin_roles_path
  click_on "Create role"
  fill_in "Role title", with: role_name
  select role_type, from: "Role type"
  select worldwide_organisation_name, from: "Worldwide organisations"
  click_on "Save"
end

When(/^I add a new "([^"]*)" translation to the role "([^"]*)" with:$/) do |locale_name, role_name, table|
  role = Role.find_by!(name: role_name)
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

When(/^I appoint "(.*?)" as the "(.*?)"$/) do |person_name, role_name|
  visit admin_roles_path
  role = Role.find_by(name: role_name)
  click_on role.name
  click_on "New appointment"
  select person_name, from: "Person"
  click_on "Save"
end

Then(/^I should be able to create a news article associated with "(.*?)" as the "(.*?)"$/) do |person_name, role_name|
  begin_drafting_news_article title: "New #{role_name}!"
  select "#{person_name}, #{role_name}", from: "Ministers"

  click_button "Save"

  assert news = NewsArticle.find_by(title: "New #{role_name}!")
  assert_equal person_name, news.role_appointments.first.person.name
end

Then(/^I should be able to appoint "([^"]*)" to the new role$/) do |person_name|
  role = Role.last
  click_on role.name
  click_on "New appointment"
  select person_name, from: "Person"
  select_date 1.day.ago.to_s, from: "Started at"
  click_on "Save"
end

Then(/^I should see "([^"]*)" listed on the "([^"]*)" organisation page$/) do |person_name, organisation_name|
  visit_organisation organisation_name
  role = find_person(person_name).roles.first
  assert_selector record_css_selector(role.current_person)
end

Then(/^I should see him listed as "([^"]*)" on the worldwide organisation page$/) do |role_name|
  visit worldwide_organisation_path(WorldwideOrganisation.last)
  person = Person.last
  role = Role.find_by!(name: role_name)

  within record_css_selector(person) do
    assert_text person.name
    assert_text role.name
  end
end

Then(/^I should see the role translation "([^"]*)" with:$/) do |locale, table|
  fields = table.rows_hash
  click_link locale
  assert_selector "input[id=role_name][value='#{fields['name']}']"
  assert_selector "#role_responsibilities", text: fields["responsibility"]
end
