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
  create(world_location_type.gsub(' ','_').to_sym, name: name)
end

Given /^an? (world location|international delegation) "([^"]*)" exists with the mission statement "([^"]*)"$/ do |world_location_type, name, mission_statement|
  create(world_location_type.gsub(' ','_').to_sym, name: name, mission_statement: mission_statement)
end

Given /^the (world location|international delegation) "([^"]*)" is inactive/ do |world_location_type, name|
  world_location = WorldLocation.find_by_name(name) || create(world_location_type.gsub(' ','_').to_sym, name: name)
  world_location.update_column(:active, false)
end

Given /^an? (world location|international delegation) "([^"]*)" exists with a translation for the locale "([^"]*)"$/ do |world_location_type, name, locale|
  location = create(world_location_type.gsub(' ','_').to_sym, name: name)
  add_translation_to_world_location(location, locale: locale, name: 'Unimportant', mission_statement: 'Unimportant')
end

When /^I view the (?:world location|international delegation) "([^"]*)"$/ do |name|
  world_location = WorldLocation.find_by_name!(name)
  visit world_location_path(world_location)
end

When /^I navigate to the "([^"]*)" (?:world location|international delegation)'s (home) page$/ do |world_location_name, page_name|
  within('.world_location nav') do
    click_link \
      case page_name
      when 'home'   then 'Home'
      end
  end
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
  fill_in 'title', with: news_article.title.split.first
  click_link 'Everywhere'
  within record_css_selector(news_article) do
    click_link "Feature"
  end
  attach_file "Select an image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When /^I feature the news article "([^"]*)" for (?:world location|international delegation) "([^"]*)"(?: with image "([^"]*)")?$/ do |news_article_title, world_location_name, image_filename|
  feature_news_article_in_world_location(news_article_title, world_location_name, image_filename)
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

When /^I visit the worldwide location "([^"]+)"$/ do |name|
  world_location = WorldLocation.find_by_name!(name)
  visit world_location_path(world_location)
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

Then /^I should see the "([^"]*)" (?:world location|international delegation)'s (home) page$/ do |world_location_name, page_name|
  title =
    case page_name
    when 'home'   then world_location_name
    end

  assert page.has_css?('title', text: title)
end

Then /^I should see a (?:world location|international delegation) called "([^"]*)"$/ do |name|
  assert page.has_css?(".world_location", text: name)
end

Then /^I should not see a link to the (?:world location|international delegation) called "([^"]*)"$/ do |text|
  refute page.has_css?(".world_location a", text: text)
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
  assert page.has_css?('.title', text: translation["title"]), "Title wasn't present"
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

Then /^I should see no featured items on the french version of the "([^"]*)" page$/ do |world_location_name|
  view_world_location_in_locale(world_location_name, "Français")
  assert page.has_no_css?('.feature'), "Feature was unexpectedly present"
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
  assert has_css?('.sortable a', text: expected_title)
  assert has_css?('.table .news_article a', text: expected_title)
end

Then /^I cannot feature "([^"]*)" on the french "([^"]*)" page due to the lack of a translation$/ do |title, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  visit admin_world_location_path(world_location)
  click_link "Features (Français)"
  fill_in 'title', with: title.split.first
  click_link 'Everywhere'
  assert page.has_no_css?("a.btn", text: "Feature")
end
