Given /^the organisation "([^"]*)" contains some policies$/ do |name|
  editions = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:organisation, name: name, editions: editions)
end

Given /^ministers "([^"]*)" and "([^"]*)" are in the "([^"]*)"$/ do |first_minister, second_minister, organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  organisation.roles << build(:role, name: first_minister)
  organisation.roles << build(:role, name: second_minister)
end

Given /^other organisations also have policies$/ do
  create(:organisation, editions: [build(:published_policy)])
  create(:organisation, editions: [build(:published_policy)])
end

Given /^two organisations "([^"]*)" and "([^"]*)" exist$/ do |first_organisation, second_organisation|
  create(:organisation, name: first_organisation)
  create(:organisation, name: second_organisation)
end

Given /^the "([^"]*)" organisation contains:$/ do |organisation_name, table|
  organisation = Organisation.find_or_create_by_name(organisation_name)
  table.hashes.each do |row|
    person = Person.find_or_create_by_name(row["Person"])
    organisation.roles.find_or_create_by_name(row["Role"], person: person)
  end
end

When /^I visit the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name(name)
  visit organisation_path(organisation)
end

Then /^I should only see published policies belonging to the "([^"]*)" organisation$/ do |name|
  organisation = Organisation.find_by_name(name)
  editions = records_from_elements(Edition, page.all(".edition"))
  assert editions.all? { |edition| organisation.editions.published.include?(edition) }
end

Then /^I should see "([^"]*)" has the "([^"]*)" role$/ do |person_name, role_name|
  # DEV NOTE! changing braces to do/end here will cause Ruby to pass the block to
  # the assert method, rather than any? - weird.
  assert page.all(".role").any? { |element|
    element.has_css?(".title", text: role_name) &&
    element.has_css?(".name", text: person_name)
  }
end
