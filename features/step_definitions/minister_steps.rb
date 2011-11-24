Given /^ministers exist:$/ do |table|
  table.hashes.each do |row|
    person = Person.find_or_create_by_name(row["Person"])
    ministerial_role = MinisterialRole.find_or_create_by_name(row["Ministerial Role"])
    create(:role_appointment, role: ministerial_role, person: person)
  end
end

Given /^"([^"]*)" is the "([^"]*)" for the "([^"]*)"$/ do |person, ministerial_role, organisation_name|
  person = Person.find_or_create_by_name(person)
  organisation = Organisation.find_by_name(organisation_name) || create(:organisation, name: organisation_name)
  role = MinisterialRole.create!(name: ministerial_role)
  organisation.ministerial_roles << role
  create(:role_appointment, role: role, person: person)
end

When /^I visit the minister page for "([^"]*)"$/ do |name|
  visit "/"
  click_link "Ministers"
  click_link name
end

Then /^I should see that the minister is responsible for the documents:$/ do |table|
  table.raw.each do |(document_title)|
    document = Document.find_by_title!(document_title)
    assert page.has_css?(record_css_selector(document), text: document.title), "document '#{document.title}' wasn't there"
  end
end

Then /^I should see that the minister is associated with the "([^"]*)"$/ do |organisation_name|
  organisation = Organisation.find_by_name!(organisation_name)
  assert page.has_css?(record_css_selector(organisation), text: organisation.name), "organisation was missing"
end