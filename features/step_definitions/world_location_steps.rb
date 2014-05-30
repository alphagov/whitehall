# encoding: utf-8

def add_translation_to_world_location(location, translation)
  translation = translation.stringify_keys
  visit admin_world_location_path(location)
  click_link "Translations"

  select translation["locale"], from: "Locale"
  click_on "Create translation"
  fill_in "Name", with: translation["name"]
  fill_in "Title", with: translation["title"]
  fill_in "Mission statement", with: translation["mission_statement"]
  click_on "Save"
end

Given /^an? (world location|international delegation) "([^"]*)" exists$/ do |world_location_type, name|
  create(world_location_type.gsub(' ', '_').to_sym, name: name)
end

Given /^an? (world location|international delegation) "([^"]*)" exists with the mission statement "([^"]*)"$/ do |world_location_type, name, mission_statement|
  create(world_location_type.gsub(' ', '_').to_sym, name: name, mission_statement: mission_statement)
end

Given /^the (world location|international delegation) "([^"]*)" is inactive/ do |world_location_type, name|
  world_location = WorldLocation.find_by_name(name) || create(world_location_type.gsub(' ', '_').to_sym, name: name)
  world_location.update_column(:active, false)
end

Given /^an? (world location|international delegation) "([^"]*)" exists with a translation for the locale "([^"]*)"$/ do |world_location_type, name, locale|
  location = create(world_location_type.gsub(' ', '_').to_sym, name: name)
  locale = Locale.find_by_language_name(locale)

  translation = LocalisedModel.new(location, locale.code)
  translation.name = 'Unimportant'
  translation.title = 'Unimportant'
  translation.save!
end

Given(/^I have an offsite link "(.*?)" for the world location "(.*?)"$/) do |title, world_location_name|
  world_location = WorldLocation.find_by_name(world_location_name)
  @offsite_link = create :offsite_link, title: title, parent: world_location
end

When /^I view the (?:world location|international delegation) "([^"]*)"$/ do |name|
  world_location = WorldLocation.find_by_name!(name)
  visit world_location_path(world_location)
end

When /^I visit the world locations page$/ do
  visit world_locations_path
end

def feature_news_article_in_world_location(news_article_title, world_location_name, image_filename = nil, locale = "English")
  image_filename ||= 'minister-of-funk.960x640.jpg'
  world_location = WorldLocation.find_by_name!(world_location_name)
  visit admin_world_location_path(world_location)
  click_link "Features (#{locale})"
  locale = Locale.find_by_language_name(locale)
  news_article = LocalisedModel.new(NewsArticle, locale.code).find_by_title(news_article_title)
  within ".filter-options" do
    select "All locations", from: :world_location
    click_button "Search"
  end
  within record_css_selector(news_article) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :feature_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When /^I feature the news article "([^"]*)" for (?:world location|international delegation) "([^"]*)"(?: with image "([^"]*)")?$/ do |news_article_title, world_location_name, image_filename|
  feature_news_article_in_world_location(news_article_title, world_location_name, image_filename)
end

When(/^I feature the offsite link "(.*?)" for  world location "(.*?)" with image "(.*?)"$/) do |offsite_link_title, world_location_name, image_filename|
  world_location = WorldLocation.find_by_name!(world_location_name)
  visit admin_world_location_path(world_location)
  click_link "Features"
  offsite_link = OffsiteLink.find_by_title(offsite_link_title)
  within record_css_selector(offsite_link) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :feature_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When(/^I add the offsite link "(.*?)" of type "(.*?)" to the world location "(.*?)"$/) do |title, type, location_name|
  world_location = WorldLocation.find_by_name!(location_name)
  visit admin_world_location_path(world_location)
  click_link "Features (English)"
  click_link "Create an offsite link"
  fill_in :offsite_link_title, with: title
  select type, from: 'offsite_link_link_type'
  fill_in :offsite_link_summary, with: "summary"
  fill_in :offsite_link_url, with: "http://gov.uk"
  click_button "Save"
end

When /^I order the featured items of the (?:world location|international delegation) "([^"]*)" to:$/ do |name, table|
  world_location = WorldLocation.find_by_name!(name)
  visit features_admin_world_location_path(world_location)
  order_features_from(table)
end

When /^I add a new translation to the world location "([^"]*)" with:$/ do |name, table|
  world_location = WorldLocation.find_by_name!(name)
  add_translation_to_world_location(world_location, table.rows_hash)
end

When /^I edit the "([^"]*)" translation for "([^"]*)" setting:$/ do |locale, name, table|
  location = WorldLocation.find_by_name!(name)
  translation = table.rows_hash
  visit admin_world_location_path(location)
  click_link "Translations"
  click_link locale
  fill_in "Name", with: translation["name"]
  fill_in "Title", with: translation["title"]
  fill_in "Mission statement", with: translation["mission_statement"]
  click_on "Save"
end

Then /^I should see the featured items of the (?:world location|international delegation) "([^"]*)" are:$/ do |name, expected_table|
  world_location = WorldLocation.find_by_name!(name)
  visit world_location_path(world_location)
  rows = find(featured_documents_selector).all('.feature')
  table = rows.collect do |row|
    [
      row.find('h2').text.strip,
      File.basename(row.find('.featured-image')['src'])
    ]
  end
  expected_table.diff!(table)
  expected_table.diff!(table)
end

Then /^I should see a (?:world location|international delegation) called "([^"]*)"$/ do |name|
  assert page.has_css?(".world_location", text: name)
end

Then /^I should not see a link to the (?:world location|international delegation) called "([^"]*)"$/ do |text|
  assert page.has_no_css?(".world_location a", text: text)
end

Then /^I should see that it is an? (world location|international delegation)$/ do |world_location_type|
  assert has_css?('.type', text: world_location_type.capitalize)
end

def view_world_location_in_locale(world_location_name, locale)
  world_location = WorldLocation.find_by_name!(world_location_name)
  visit world_location_path(world_location)
  click_link locale
end

Then /^when viewing the (?:world location|international delegation) "([^"]*)" with the locale "([^"]*)" I should see:$/ do |world_location_name, locale, table|
  view_world_location_in_locale(world_location_name, locale)
  translation = table.rows_hash
  assert page.has_css?('h1', text: translation["title"]), "Title wasn't present"
  assert page.has_css?('.mission_statement', text: translation["mission_statement"]), "Mission statement wasn't present"
end

Then /^I should be able to associate "([^"]+)" with the (?:world location|international delegation) "([^"]+)"$/ do |title, location|
  begin_editing_document title
  select location, from: "edition_world_location_ids"
  click_on "Save"
end

When /^I click through to see all the announcements for (?:international delegation|world location) "([^"]*)"$/ do |name|
  visit world_location_path(WorldLocation.find_by_name!(name))
  within '#announcements' do
    click_link 'See all'
  end
end

Given /^an english news article called "([^"]*)" related to the world location$/ do |title|
  world_location = WorldLocation.last
  create(:published_news_article, title: title, world_locations: [world_location])
end

When /^I feature "([^"]*)" on the english "([^"]*)" page$/ do |title, overseas_territory_name|
  feature_news_article_in_world_location(title, overseas_territory_name)
end

When(/^I stop featuring the offsite link "(.*?)" for the world location "(.*?)"$/) do |offsite_link_name, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  visit features_admin_world_location_path(world_location)
  offsite_link = OffsiteLink.find_by_title!(offsite_link_name)
  within record_css_selector(offsite_link) do
    click_on "Unfeature"
  end
end

Then /^I should see no featured items on the french version of the "([^"]*)" page$/ do |world_location_name|
  view_world_location_in_locale(world_location_name, "Français")
  assert page.has_no_css?('.feature'), "Feature was unexpectedly present"
end

Then(/^I should see the edit offsite link "(.*?)" on the "(.*?)" world location page$/) do |title, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  offsite_link = OffsiteLink.find_by_title!(title)
  visit world_location_path(world_location)
  page.has_link?(title, href: edit_admin_world_location_offsite_link_path(world_location.id, offsite_link.id))
end

Given /^a world location "([^"]*)" exists in both english and french$/ do |name|
  location = create(:world_location, name: name)
  add_translation_to_world_location(location, locale: "French", name: 'Unimportant', mission_statement: 'Unimportant')
end

Given /^there is a news article "([^"]*)" in english \("([^"]*)" in french\) related to the world location$/ do |english_title, french_title|
  world_location = WorldLocation.last
  create(:published_news_article, title: english_title, world_locations: [world_location], translated_into: {
    fr: {
      title: french_title
    }
  })
end

When /^I feature "([^"]*)" on the french "([^"]*)" page$/ do |news_article_title, world_location_name|
  feature_news_article_in_world_location(news_article_title, world_location_name, nil, "Français")
end

Then /^I should see "([^"]*)" as the title of the feature on the french "([^"]*)" page$/ do |expected_title, world_location_name|
  view_world_location_in_locale(world_location_name, "Français")
  assert page.has_css?('.feature h2', text: expected_title)
end

Then /^I should see "([^"]*)" featured on the public facing "([^"]*)" page$/ do |expected_title, name|
  visit world_location_path(WorldLocation.find_by_name!(name))
  assert page.has_css?('.feature h2', text: expected_title)
end

Then /^I should see "([^"]*)" as the title of the featured item on the french "([^"]*)" admin page$/ do |expected_title, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  visit admin_world_location_path(world_location)
  click_link "Features (Français)"
  assert has_css?('.title', text: expected_title)
end

Then /^I cannot feature "([^"]*)" on the french "([^"]*)" page due to the lack of a translation$/ do |title, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  visit admin_world_location_path(world_location)
  click_link "Features (Français)"
  fill_in 'title', with: title.split.first
  assert page.has_no_css?("a.btn", text: "Feature")
end

Then /^clicking on "([^"]*)" on the french "([^"]*)" page should take me to the french version of the article$/ do |title, world_location_name|
  view_world_location_in_locale(world_location_name, "Français")

  within '.feature h2' do
    click_on title
  end

  assert page.has_css?('h1', text: title)
  assert page.has_css?('.available-languages li.translation span', text: 'Français')
end

Then(/^there should be nothing featured on the home page of world location "(.*?)"$/) do |name|
  visit world_location_path(name)
  rows = find(featured_documents_selector).all('.feature')
  assert rows.empty?
end
