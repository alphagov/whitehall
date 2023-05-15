Given(/^"([^"]*)" is the "([^"]*)" for the "([^"]*)"$/) do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 2.years.ago)
end

Given(/^"([^"]*)" is the "([^"]*)" for the "([^"]*)" and also attends cabinet$/) do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 2.years.ago, role_options: { attends_cabinet_type_id: 1 })
end

When(/^I visit the ministers page$/) do
  visit ministers_page
end

Then(/^I should see that "([^"]*)" is a minister in the "([^"]*)"$/) do |minister_name, organisation_name|
  organisation = Organisation.find_by!(name: organisation_name)
  within record_css_selector(organisation) do
    expect(page).to have_selector(".current-appointee", text: minister_name)
  end
end

Then(/^I should see that "([^"]*)" is a minister in the "([^"]*)" with role "([^"]*)"$/) do |minister_name, organisation_name, role|
  organisation = Organisation.find_by!(name: organisation_name)
  within record_css_selector(organisation) do
    expect(page).to have_selector(".current-appointee", text: minister_name)
    expect(page).to have_selector(".app-person__roles", text: role)
  end
end

Given(/^"([^"]*)" is a commons whip "([^"]*)" for the "([^"]*)"$/) do |person_name, ministerial_role, organisation_name|
  create_role_appointment(
    person_name,
    ministerial_role,
    organisation_name,
    2.years.ago,
    role_options: { whip_organisation_id: Whitehall::WhipOrganisation::WhipsHouseOfCommons.id },
  )
end

Then(/^I should see that "([^"]*)" is a commons whip "([^"]*)"$/) do |minister_name, role_title|
  within record_css_selector(Whitehall::WhipOrganisation::WhipsHouseOfCommons) do
    expect(page).to have_selector(".current-appointee", text: minister_name)
    expect(page).to have_selector(".app-person__roles", text: role_title)
  end
end

Then(/^I should see that "([^"]*)" also attends cabinet$/) do |minister_name|
  within "#also-attends-cabinet" do
    expect(page).to have_selector(".current-appointee", text: minister_name)
  end
end

Given(/^two cabinet ministers "([^"]*)" and "([^"]*)"$/) do |person1, person2|
  create(:role_appointment, person: create(:person, forename: person1), role: create(:ministerial_role, cabinet_member: true))
  create(:role_appointment, person: create(:person, forename: person2), role: create(:ministerial_role, cabinet_member: true))
end

Given(/^two whips "([^"]*)" and "([^"]*)"$/) do |person1, person2|
  whip_organisation_id = Whitehall::WhipOrganisation::WhipsHouseOfCommons.id
  create(
    :role_appointment,
    person: create(:person, forename: person1),
    role: create(:ministerial_role, whip_organisation_id:, cabinet_member: false),
  )
  create(
    :role_appointment,
    person: create(:person, forename: person2),
    role: create(:ministerial_role, whip_organisation_id:, cabinet_member: false),
  )
end

When(/^I order the (?:cabinet ministers|whips) "([^"]*)", "([^"]*)"$/) do |role1, role2|
  visit admin_cabinet_ministers_path
  [role1, role2].each_with_index do |role, index|
    fill_in(role, with: index)
  end
  click_button "Save"
end

Then(/^I should see "([^"]*)", "([^"]*)" in that order on the ministers page$/) do |person1, person2|
  visit ministers_page
  actual = all(".person .current-appointee").map(&:text)
  expect([person1, person2]).to eq(actual)
end

Then(/^I should see "([^"]*)", "([^"]*)" in that order on the whips section of the ministers page$/) do |person1, person2|
  visit ministers_page
  actual = all(".whips .current-appointee").map(&:text)
  expect([person1, person2]).to eq(actual)
end
