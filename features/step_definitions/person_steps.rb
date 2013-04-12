Given /^a person called "([^"]*)"$/ do |name|
  create_person(name)
end

Given /^a person called "([^"]*)" exists with the biography "([^"]*)"$/ do |name, biography|
  create_person(name, biography: biography)
end

Given /^a person called "([^"]*)" exists with a translation for the locale "([^"]*)"$/ do |name, locale|
  person = create_person(name, biography: "Unimportant")
  add_translation_to_person(person, locale: locale, biography: 'Unimportant')
end

Given /^"([^"]*)" is a minister with a history$/ do |name|
  person = create_person(name)
  role = create(:ministerial_role)
  create(:ministerial_department, ministerial_roles: [role])
  create(:role_appointment, role: role, person: person, started_at: 2.years.ago, ended_at: 1.year.ago)
  role = create(:ministerial_role)
  create(:ministerial_department, ministerial_roles: [role])
  create(:role_appointment, role: role, person: person, started_at: 1.year.ago, ended_at: nil)
end

When /^I visit the person page for "([^"]*)"$/ do |name|
  visit person_url(find_person(name))
end

When /^I add a new person called "([^"]*)"$/ do |name|
  visit_people_admin
  click_link "Create Person"
  fill_in_person_name name
  fill_in "Biography", with: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  attach_file "Image", jpg_image
  click_button "Save"
end

When /^I update the person called "([^"]*)" to have the name "([^"]*)"$/ do |old_name, new_name|
  visit_people_admin
  click_link old_name
  fill_in_person_name new_name
  fill_in "Biography", with: "Vivamus fringilla libero et augue fermentum eget molestie felis accumsan."
  click_button "Save"
end

When /^I remove the person "([^"]*)"$/ do |name|
  visit_people_admin
  person = find_person(name)
  within(record_css_selector(person)) do
    click_button 'delete'
  end
end

When /^I add a new "([^"]*)" translation to the person "([^"]*)" with:$/ do |locale, name, table|
  person = find_person(name)
  add_translation_to_person(person, table.rows_hash.merge(locale: locale))
end

When /^I edit the "([^"]*)" translation for the person called "([^"]*)" setting:$/ do |locale, name, table|
  person = find_person(name)
  translation = table.rows_hash.stringify_keys
  visit admin_people_path
  within record_css_selector(person) do
    click_link "Manage translations"
  end
  click_link locale
  fill_in "Biography", with: translation["biography"]
  click_on "Save"
end

Then /^I should be able to see "([^"]*)" in the list of people$/ do |name|
  visit_people_admin
  assert page.has_css?(".person .name", text: name)
end

Then /^I should not be able to see "([^"]*)" in the list of people$/ do |name|
  assert page.has_no_css?(".person .name", text: name)
end

Then /^I should see information about the person "([^"]*)"$/ do |name|
  person = find_person(name)
  assert page.has_css?(".name", text: person.name)
  assert page.has_css?(".biography", text: person.biography)
end

Then /^I should see the worldwide organisation listed on his public page$/ do
  person = Person.last
  organisation = WorldwideOrganisation.last
  visit person_url(person)

  within record_css_selector(person) do
    assert page.has_content?(person.name)
    assert page.has_css?("#current-roles a", text: organisation.name)
  end
end

Then /^when viewing the person "([^"]*)" with the locale "([^"]*)" I should see:$/ do |name, locale, table|
  person = find_person(name)
  translation = table.rows_hash
  visit person_path(person)
  click_link locale
  assert page.has_css?('.biography', text: translation["biography"]), "Biography wasn't present"
end
