Given /^the organisation "([^"]*)" contains some policies$/ do |name|
  editions = Array.new(5) { build(:published_edition) } + Array.new(2) { build(:draft_edition) }
  create(:organisation, name: name, editions: editions)
end

Given /^ministers "([^"]*)" and "([^"]*)" are in the "([^"]*)"$/ do |first_minister, second_minister, organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  organisation.roles << build(:role, name: first_minister)
  organisation.roles << build(:role, name: second_minister)
end

Given /^other organisations also have policies$/ do
  create(:organisation, editions: [build(:published_edition)])
  create(:organisation, editions: [build(:published_edition)])
end

Given /^two organisations "([^"]*)" and "([^"]*)" exist$/ do |first_organisation, second_organisation|
  create(:organisation, name: first_organisation)
  create(:organisation, name: second_organisation)
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

Then /^I should see ministers "([^"]*)" and "([^"]*)"$/ do |first_minister, second_minister|
  assert has_css?(".role", text: first_minister)
  assert has_css?(".role", text: second_minister)
end
