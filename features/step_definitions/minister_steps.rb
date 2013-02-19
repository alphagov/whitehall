Given /^ministers exist:$/ do |table|
  table.hashes.each do |row|
    person = find_or_create_person(row["Person"])
    ministerial_role = MinisterialRole.find_or_create_by_name(row["Ministerial Role"])
    create(:role_appointment, role: ministerial_role, person: person)
  end
end

Given /^"([^"]*)" used to be the "([^"]*)" for the "([^"]*)"$/ do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 3.years.ago => 2.years.ago)
end

Given /^"([^"]*)" is the "([^"]*)" for the "([^"]*)"$/ do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 2.years.ago)
end

Given /^the role "([^"]*)" has the responsibilities "([^"]*)"$/ do |role_name, responsibilities|
  ministerial_role = MinisterialRole.find_or_create_by_name(role_name)
  ministerial_role.responsibilities = responsibilities
  ministerial_role.save!
end

When /^I visit the minister page for "([^"]*)"$/ do |name|
  visit ministers_page
  click_link name
end

When /^I visit the ministers page$/ do
  visit ministers_page
end

Then /^I should see that "([^"]*)" is a minister in the "([^"]*)"$/ do |minister_name, organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  within record_css_selector(organisation) do
    assert page.has_css?('.current-appointee', text: minister_name)
  end
end

Then /^I should see that the minister is associated with the "([^"]*)"$/ do |organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  assert page.has_css?(record_css_selector(organisation)), "organisation was missing"
end

Then /^I should see that the minister has responsibilities "([^"]*)"$/ do |responsibilities|
  assert page.has_css?(".responsibilities", text: responsibilities)
end

When /^there is a reshuffle and "([^"]*)" is now "([^"]*)"$/ do |person_name, ministerial_role|
  person = find_or_create_person(person_name)
  role = MinisterialRole.find_by_name(ministerial_role)
  create(:role_appointment, role: role, person: person, make_current: true)
end

Given /^"([^"]*)" is a commons whip "([^"]*)" for the "([^"]*)"$/ do |person_name, ministerial_role, organisation_name|
  create_role_appointment(person_name, ministerial_role, organisation_name, 2.years.ago,
    role_options: {whip_organisation_id: Whitehall::WhipOrganisation::WhipsHouseOfCommons.id})
end

Then /^I should see that "([^"]*)" is a commons whip "([^"]*)"$/ do |minister_name, role_title|
  within record_css_selector(Whitehall::WhipOrganisation::WhipsHouseOfCommons) do
    assert page.has_css?('.current-appointee', text: minister_name)
    assert page.has_css?('.role', text: role_title)
  end
end