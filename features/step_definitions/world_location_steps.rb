Given /^an? (country|overseas territory|international delegation) "([^"]*)" exists$/ do |world_location_type, name|
  create(world_location_type.gsub(' ','_').to_sym, name: name)
end

Given /^the (country|overseas territory|international delegation) "([^"]*)" is inactive/ do |world_location_type, name|
  world_location = WorldLocation.find_by_name(name) || create(world_location_type.gsub(' ','_').to_sym, name: name)
  world_location.update_column(:active, false)
end

When /^I view the (?:country|overseas territory|international delegation) "([^"]*)"$/ do |name|
  world_location = WorldLocation.find_by_name!(name)
  visit world_location_path(world_location)
end

When /^I add contact details for the embassy in "([^"]*)"$/ do |name|
  visit admin_root_path
  click_link "World locations"
  click_link name
  fill_in "Embassy address", with: "1 Rue du la Vache"
  fill_in "Embassy telephone", with: "08 71 23 45 67"
  fill_in "Embassy email", with: "hubert.bonniseur-de-la-bath@oss.fr"
  click_button "Save"
end

When /^I navigate to the "([^"]*)" (?:country|overseas territory|international delegation)'s (about|home) page$/ do |world_location_name, page_name|
  within('.world_location nav') do
    click_link \
      case page_name
      when 'about'  then 'About'
      when 'home'   then 'Home'
      end
  end
end

When /^I visit the world locations page$/ do
  visit world_locations_path
end

When /^I set the featured news articles of the (?:country|overseas territory|international delegation) "([^"]*)" to:$/ do |name, table|
  world_location = WorldLocation.find_by_name!(name)
  visit edit_admin_world_location_path(world_location)
  table.rows.each do |title|
    news_article = NewsArticle.find_by_title(title)
    within record_css_selector(news_article) do
      click_button "Feature"
    end
  end
end

Then /^I should see the featured news articles of the (?:country|overseas territory|international delegation) "([^"]*)" are:$/ do |name, expected_table|
  world_location = WorldLocation.find_by_name!(name)
  visit world_location_path(world_location)
  rows = find(featured_documents_selector).all('.news_article')
  table = rows.map { |r| r.all('a.title').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see contact details for the embassy in "([^"]*)"$/ do |name|
  world_location = WorldLocation.find_by_name!(name)
  visit world_location_path(world_location)
  assert page.has_css?(".embassy_address", world_location.embassy_address)
  assert page.has_css?(".embassy_telephone", world_location.embassy_telephone)
  assert page.has_css?(".embassy_email", world_location.embassy_email)
end

Then /^I should see the world location navigation$/ do
  assert page.has_css?('.world_location nav')
end

Then /^I should see the "([^"]*)" (?:country|overseas territory|international delegation)'s (about|home) page$/ do |world_location_name, page_name|
  title =
    case page_name
    when 'about'  then "About #{world_location_name}"
    when 'home'   then world_location_name
    end

  assert page.has_css?('title', text: title)
end

Then /^I should see a (?:country|overseas territory|international delegation) called "([^"]*)"$/ do |name|
  assert page.has_css?(".world_location", text: name)
end

Then /^I should not see a link to the (?:country|overseas territory|international delegation) called "([^"]*)"$/ do |text|
  refute page.has_css?(".world_location a", text: text)
end

Then /^the (?:country|overseas territory|international delegation) called "([^"]*)" should be featured$/ do |name|
  world_location = WorldLocation.find_by_name(name)
  assert has_css?("#{record_css_selector(world_location)}.featured")
end

Then /^I should see that it is an? (country|overseas territory|international delegation)$/ do |world_location_type|
  assert has_css?('.world-location.type', text: world_location_type.capitalize)
end
