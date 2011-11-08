Given /^a country "([^"]*)"$/ do |name|
  create(:country, name: name)
end

When /^I view the list of countries$/ do
  visit root_path
  click_link "Countries"
end

Then /^I should see the country "([^"]*)"$/ do |name|
  country = Country.find_by_name(name)
  assert page.has_css?(record_css_selector(country))
end
