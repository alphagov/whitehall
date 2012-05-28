Given /^ministers exist:$/ do |table|
  table.hashes.each do |row|
    person = find_or_create_person(row["Person"])
    ministerial_role = MinisterialRole.find_or_create_by_name(row["Ministerial Role"])
    create(:role_appointment, role: ministerial_role, person: person)
  end
end

Given /^"([^"]*)" is the "([^"]*)" for the "([^"]*)"$/ do |person_name, ministerial_role, organisation_name|
  person = find_or_create_person(person_name)
  organisation = Organisation.find_by_name(organisation_name) || create(:organisation, name: organisation_name)
  role = MinisterialRole.create!(name: ministerial_role)
  organisation.ministerial_roles << role
  create(:role_appointment, role: role, person: person)
end

Given /^the role "([^"]*)" has the responsibilities "([^"]*)"$/ do |role_name, responsibilities|
  ministerial_role = MinisterialRole.find_or_create_by_name(role_name)
  ministerial_role.responsibilities = responsibilities
  ministerial_role.save!
end

When /^I visit the minister page for "([^"]*)"$/ do |name|
  visit homepage
  click_link "Ministers"
  click_link name
end

Then /^I should see that the minister is responsible for the documents:$/ do |table|
  table.raw.each do |(document_title)|
    edition = Edition.find_by_title!(document_title)
    assert page.has_css?(record_css_selector(edition), text: edition.title), "document '#{edition.title}' wasn't there"
  end
end

Then /^I should see that the minister is associated with the "([^"]*)"$/ do |organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  assert page.has_css?(record_css_selector(organisation)), "organisation was missing"
end

Then /^I should see that the minister has a biography "([^"]*)"$/ do |biography|
  assert page.has_css?(".biography", text: biography)
end

Then /^I should see that the minister has responsibilities "([^"]*)"$/ do |responsibilities|
  assert page.has_css?(".responsibilities", text: responsibilities)
end
