Given /^a person called "([^"]*)"$/ do |name|
  create_person(name)
end

Given /^the person "([^"]*)" has a biography "([^"]*)"$/ do |name, biography|
  person = find_person(name)
  person.update_attributes!(biography: biography)
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

def visit_people_admin
  visit admin_root_path
  click_link "People"
end