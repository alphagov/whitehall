Given /^a person called "([^"]*)"$/ do |name|
  create_person(name)
end

Given /^the person "([^"]*)" has a biography "([^"]*)"$/ do |name, biography|
  person = find_person(name)
  person.update_attributes!(biography: biography)
end

Given /^"([^"]*)" is a minister with a history$/ do |name|
  person = create_person(name)
  role = create(:ministerial_role)
  create(:organisation, ministerial_roles: [role])
  create(:role_appointment, role: role, person: person, started_at: 2.years.ago, ended_at: 1.year.ago)
  role = create(:ministerial_role)
  create(:organisation, ministerial_roles: [role])
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
  attach_file "Image", Rails.root.join("features/fixtures/minister-of-soul.jpg")
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

Then /^I should be able to see "([^"]*)" in the list of people$/ do |name|
  visit_people_admin
  assert page.has_css?(".person .name", text: name)
end

Then /^I should not be able to see "([^"]*)" in the list of people$/ do |name|
  assert page.has_no_css?(".person .name", text: name)
end

Then /^I should see the biography and roles held by "([^"]*)"$/ do |name|
  person = find_person(name)
  assert page.has_css?(".name", text: person.name)
  assert page.has_css?(".biography", text: person.biography)
end

def visit_people_admin
  visit admin_root_path
  click_link "People"
end