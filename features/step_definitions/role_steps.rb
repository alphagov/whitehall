When /^I add a new "([^"]*)" role named "([^"]*)" to the "([^"]*)"$/ do |role_type, role_name, organisation_name|
  @role_name = role_name

  visit admin_roles_path
  click_on "Create Role"
  fill_in "Name", with: role_name
  select role_type, from: "Type"
  select organisation_name, from: "Organisations"
  click_on "Save"
end

When /^I add a new "([^"]*)" role named "([^"]*)" to the "([^"]*)" office$/ do |role_type, role_name, office_name|
  visit admin_roles_path
  click_on "Create Role"
  fill_in "Name", with: role_name
  select role_type, from: "Type"
  select office_name, from: "Worldwide offices"
  click_on "Save"
end

Then /^I should be able to appoint "([^"]*)" to the new role$/ do |person_name|
  click_on @role_name
  click_on "New appointment"
  select person_name, from: "Person"
  select_date "Started at", with: 1.day.ago.to_s
  click_on "Save"
end

Then /^I should see "([^"]*)" listed on the "([^"]*)" organisation page$/ do |person_name, organisation_name|
  visit_organisation organisation_name
  role = find_person(person_name).roles.first
  assert page.has_css?(record_css_selector(role.current_person))
end

Then /^I should see "([^"]*)" listed as "([^"]*)" on the "([^"]*)" office page$/ do |person_name, role_name, office_name|
  visit_worldwide_office_page office_name
  person = find_person(person_name)
  role = Role.find_by_name!(role_name)

  within record_css_selector(person) do
    assert page.has_content?(person.name)
    assert page.has_content?(role.name)
  end
end
