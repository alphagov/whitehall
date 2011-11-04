Given /^a person called "([^"]*)"$/ do |name|
  create(:person, name: name)
end

When /^I add a new person called "([^"]*)"$/ do |name|
  visit_people_admin
  click_link "Create Person"
  fill_in "Name", with: name
  click_button "Save"
end

When /^I update the person called "([^"]*)" to have the name "([^"]*)"$/ do |old_name, new_name|
  visit_people_admin
  click_link old_name
  fill_in "Name", with: new_name
  click_button "Save"
end

When /^I remove the person "([^"]*)"$/ do |name|
  visit_people_admin
  person = Person.find_by_name!(name)
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