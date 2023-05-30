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

When(/^I add a new person called "([^"]*)"$/) do |name|
  visit_people_admin
  click_link using_design_system? ? "Create new person" : "Create person"
  fill_in_person_name name
  fill_in "Biography", with: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  attach_file using_design_system? ? "Upload a file" : "Image", jpg_image
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
  click_link "Delete" if using_design_system?
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
  click_link using_design_system? ? "Edit #{locale}" : locale
  fill_in "Biography", with: text
  click_on "Save"
end

Then(/^I should be able to see "([^"]*)" in the list of people$/) do |name|
  visit_people_admin
  if using_design_system?
    expect(page).to have_selector(".govuk-table__row:nth-child(1)", text: name)
  else
    expect(page).to have_selector(".person .name", text: name)
  end
end

Then(/^I should not be able to see "([^"]*)" in the list of people$/) do |name|
  expect(page).to_not have_selector(".person .name", text: name)
end

Then(/^I should see the translation "([^"]*)" and body text "([^"]*)"$/) do |locale, text|
  if using_design_system?
    within ".govuk-table" do
      expect(page).to have_content(locale)
      click_link "Edit #{locale}"
    end
  else
    within "#person-translations" do
      expect(page).to have_selector(".locale", text: locale)
      click_on locale
    end
  end

  expect(page).to have_content(text)
end
