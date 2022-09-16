Given(/^a person called "([^"]*)"$/) do |name|
  @person = create_person(name)
end

Given(/^a person called "([^"]*)" exists with the biography "([^"]*)"$/) do |name, biography|
  create_person(name, biography:)
end

Given(/^a person called "([^"]*)" exists with a translation for the locale "([^"]*)"$/) do |name, locale|
  person = create_person(name, biography: "Unimportant")
  add_translation_to_person(person, locale:, biography: "Unimportant")
end

Given(/^a person called "([^"]*)" exists in the role of "([^"]*)"$/) do |name, role_name|
  @person = create_person(name)
  @role = create(:ministerial_role, supports_historical_accounts: true, name: role_name)
  create(:role_appointment, role: @role, person: @person)
end

When(/^I add a new person called "([^"]*)"$/) do |name|
  visit_people_admin
  click_link "Create person"
  fill_in_person_name name
  fill_in "Biography", with: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  attach_file "Image", jpg_image
  click_button "Save"
end

When(/^I update the person called "([^"]*)" to have the name "([^"]*)"$/) do |old_name, new_name|
  visit_people_admin
  click_link old_name
  click_on "Edit"
  fill_in_person_name new_name
  fill_in "Biography", with: "Vivamus fringilla libero et augue fermentum eget molestie felis accumsan."
  click_button "Save"
end

When(/^I remove the person "([^"]*)"$/) do |name|
  visit_people_admin
  click_link name
  click_button "Delete"
end

When(/^I add a new "([^"]*)" translation to the person "([^"]*)" setting biography to "([^"]*)"$/) do |locale, name, text|
  person = find_person(name)
  add_translation_to_person(person, locale:, biography: text)
end

When(/^I edit the "([^"]*)" translation for the person "([^"]*)" updating the biography to "([^"]*)"$/) do |locale, name, text|
  person = find_person(name)

  visit admin_person_path(person)
  click_link "Translations"
  click_link locale
  fill_in "Biography", with: text
  click_on "Save"
end

Then(/^I should be able to see "([^"]*)" in the list of people$/) do |name|
  visit_people_admin
  expect(page).to have_selector(".person .name", text: name)
end

Then(/^I should not be able to see "([^"]*)" in the list of people$/) do |name|
  expect(page).to_not have_selector(".person .name", text: name)
end

Then(/^I should see the translation "([^"]*)" and body text "([^"]*)"$/) do |locale, text|
  within "#person-translations" do
    expect(page).to have_selector(".locale", text: locale)
    click_on locale
  end

  expect(page).to have_content(text)
end
