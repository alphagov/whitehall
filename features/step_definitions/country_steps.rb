Given /^a country "([^"]*)" exists$/ do |name|
  create(:country, name: name)
end

Given /^the country "([^"]*)" is inactive/ do |name|
  country = Country.find_by_name(name) || create(:country, name: name)
  country.update_column(:active, false)
end

When /^I view the list of countries$/ do
  visit root_path
  click_link "UK and the world"
end

When /^I view the country "([^"]*)"$/ do |name|
  country = Country.find_by_name!(name)
  visit country_path(country)
end

When /^I add contact details for the embassy in "([^"]*)"$/ do |name|
  visit admin_root_path
  click_link "Countries"
  click_link name
  fill_in "Embassy address", with: "1 Rue du la Vache"
  fill_in "Embassy telephone", with: "08 71 23 45 67"
  fill_in "Embassy email", with: "hubert.bonniseur-de-la-bath@oss.fr"
  click_button "Save"
end

When /^I navigate to the "([^"]*)" country's (about|home) page$/ do |country_name, page_name|
  within('.country nav') do
    click_link \
      case page_name
      when 'about'  then 'About'
      when 'home'   then 'Home'
      end
  end
end

When /^I visit the countries page$/ do
  visit countries_path
end

Then /^I should see the country "([^"]*)"$/ do |name|
  country = Country.find_by_name!(name)
  assert page.has_css?(record_css_selector(country))
end

Then /^I should see contact details for the embassy in "([^"]*)"$/ do |name|
  country = Country.find_by_name!(name)
  visit country_path(country)
  assert page.has_css?(".embassy_address", country.embassy_address)
  assert page.has_css?(".embassy_telephone", country.embassy_telephone)
  assert page.has_css?(".embassy_email", country.embassy_email)
end

Then /^I should see the country navigation$/ do
  assert page.has_css?('.country nav')
end

Then /^I should see the "([^"]*)" country's (about|home) page$/ do |country_name, page_name|
  title =
    case page_name
    when 'about'  then "About #{country_name}"
    when 'home'   then country_name
    end

  assert page.has_css?('title', text: title)
end

Then /^I should see a country called "([^"]*)"$/ do |name|
  assert page.has_css?(".country", text: name)
end

Then /^I should not see a link to the country called "([^"]*)"$/ do |text|
  refute page.has_css?(".country a", text: text)
end

Then /^the country called "([^"]*)" should be featured$/ do |name|
  country = Country.find_by_name(name)
  assert has_css?("#featured-countries #{record_css_selector(country)}")
end
