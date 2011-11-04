Given /^the organisation "([^"]*)" contains some policies$/ do |name|
  documents = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:organisation, name: name, documents: documents)
end

Given /^other organisations also have policies$/ do
  create(:organisation, documents: [build(:published_policy)])
  create(:organisation, documents: [build(:published_policy)])
end

Given /^two organisations "([^"]*)" and "([^"]*)" exist$/ do |first_organisation, second_organisation|
  create(:organisation, name: first_organisation)
  create(:organisation, name: second_organisation)
end

Given /^the "([^"]*)" organisation contains:$/ do |organisation_name, table|
  organisation = Organisation.find_or_create_by_name(organisation_name)
  table.hashes.each do |row|
    person = Person.find_or_create_by_name(row["Person"])
    ministerial_role = MinisterialRole.find_or_create_by_name(row["Ministerial Role"])
    organisation.ministerial_roles << ministerial_role
    person.ministerial_roles << ministerial_role
  end
end

When /^I visit the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name!(name)
  visit organisation_path(organisation)
end

Then /^I should only see published policies belonging to the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name!(name)
  documents = records_from_elements(Document, page.all(".document"))
  assert documents.all? { |document| organisation.documents.published.include?(document) }
end

Then /^I should see "([^"]*)" has the "([^"]*)" ministerial role$/ do |person_name, role_name|
  person = Person.find_by_name!(person_name)
  ministerial_role = person.ministerial_roles.find_by_name!(role_name)
  assert page.has_css?(".ministerial_role", text: ministerial_role.to_s)
end
