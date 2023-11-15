def add_translation_to_world_location(location, translation)
  translation = translation.stringify_keys
  visit admin_world_location_news_path(location)
  click_link "Translations"

  select translation["locale"], from: "Locale"
  click_on "Create translation"
  fill_in "Name", with: translation["name"]
  fill_in "Title", with: translation["title"]
  fill_in "Mission statement", with: translation["mission_statement"]
  click_on "Save"
end

Given(/^an? (world location|international delegation) "([^"]*)" exists$/) do |world_location_type, name|
  world_location = create(world_location_type.tr(" ", "_").to_sym, name: name)
  # We cannot at the moment set active to be true directly on the international delegation factory, because this will trigger code for searchable
  # that requires a world location news to exist, but this has not been created yet at the point of creating the international delegation
  # Further refactoring of world locations / international delegations should fix this issue
  world_location.update!(active: true)
end

Given(/^an? (world location|international delegation) "([^"]*)" exists with the mission statement "([^"]*)"$/) do |world_location_type, name, mission_statement|
  WorldLocationNewsWorker.any_instance.stubs(:perform).returns(true)
  create(world_location_type.tr(" ", "_").to_sym, name: name, active: true, mission_statement: mission_statement)
end

Given(/^the (world location|international delegation) "([^"]*)" is inactive/) do |world_location_type, name|
  WorldLocationNewsWorker.any_instance.stubs(:perform).returns(true)
  world_location = WorldLocation.find_by(name: name) || create(world_location_type.tr(" ", "_").to_sym, name: name, active: true)
  world_location.update_column(:active, false)
end

Given(/^an? (world location|international delegation) "([^"]*)" exists with a translation for the locale "([^"]*)"$/) do |world_location_type, name, locale|
  location = create(world_location_type.tr(" ", "_").to_sym, name: name)
  # We cannot at the moment set active to be true directly on the international delegation factory, because this will trigger code for searchable
  # that requires a world location news to exist, but this has not been created yet at the point of creating the international delegation
  # Further refactoring of world locations / international delegations should fix this issue
  location.update!(active: true)
  locale = Locale.find_by_language_name(locale)

  translation = LocalisedModel.new(location, locale.code)
  translation.name = "Unimportant"
  translation.save!
end

Given(/^I have an offsite link "(.*?)" for the (?:world location|international delegation) "(.*?)"$/) do |title, world_location_name|
  world_location = WorldLocation.find_by(name: world_location_name)
  @offsite_link = create :offsite_link, title: title, parent: world_location.world_location_news
end

When(/^I view the (?:world location|international delegation) "([^"]*)"$/) do |name|
  world_location = WorldLocation.find_by!(name: name)
  visit world_location_path(world_location)
end

When(/^I visit the world locations page$/) do
  visit world_locations_path
end

def feature_news_article_in_world_location(news_article_title, world_location_name, image_filename = nil, locale = "English")
  image_filename ||= "minister-of-funk.960x640.jpg"
  world_location = WorldLocation.find_by!(name: world_location_name)
  visit admin_world_location_news_path(world_location)
  click_link "Features (#{locale})"
  locale = Locale.find_by_language_name(locale)
  news_article = LocalisedModel.new(NewsArticle, locale.code).find_by(title: news_article_title)
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

When(/^I feature the news article "([^"]*)" for (?:world location|international delegation) "([^"]*)"(?: with image "([^"]*)")?$/) do |news_article_title, world_location_name, image_filename|
  feature_news_article_in_world_location(news_article_title, world_location_name, image_filename)
end

When(/^I feature the offsite link "(.*?)" for (?:world location|international delegation) "(.*?)" with image "(.*?)"$/) do |offsite_link_title, world_location_name, image_filename|
  world_location = WorldLocation.find_by!(name: world_location_name)
  visit admin_world_location_news_path(world_location)
  click_link "Features"
  offsite_link = OffsiteLink.find_by(title: offsite_link_title)
  within record_css_selector(offsite_link) do
    click_link "Feature"
  end
  attach_file "Select a 960px wide and 640px tall image to be shown when featuring", Rails.root.join("test/fixtures/#{image_filename}")
  fill_in :feature_alt_text, with: "An accessible description of the image"
  click_button "Save"
end

When(/^I add the offsite link "(.*?)" of type "(.*?)" to the (?:world location|international delegation) "(.*?)"$/) do |title, type, location_name|
  world_location = WorldLocation.find_by!(name: location_name)
  visit admin_world_location_news_path(world_location)
  click_link "Features (English)"
  click_link "Create a non-GOV.UK government link"
  fill_in :offsite_link_title, with: title
  select type, from: "offsite_link_link_type"
  fill_in :offsite_link_summary, with: "summary"
  fill_in :offsite_link_url, with: "http://gov.uk"
  click_button "Save"
end

When(/^I order the featured items of the (?:world location|international delegation) "([^"]*)" to:$/) do |name, table|
  world_location = WorldLocation.find_by!(name: name)
  visit features_admin_world_location_news_path(world_location)
  order_features_from(table)
end

When(/^I add a new translation to the (?:world location|international delegation) "([^"]*)" with:$/) do |name, table|
  world_location = WorldLocation.find_by!(name: name)
  add_translation_to_world_location(world_location, table.rows_hash)
end

When(/^I edit the "([^"]*)" translation for "([^"]*)" setting:$/) do |locale, name, table|
  location = WorldLocation.find_by!(name: name)
  translation = table.rows_hash
  visit admin_world_location_news_path(location)
  click_link "Translations"
  click_link locale
  fill_in "Name", with: translation["name"]
  fill_in "Title", with: translation["title"]
  fill_in "Mission statement", with: translation["mission_statement"]
  click_on "Save"
end

Then(/^I should see the featured items of the (?:world location|international delegation) "([^"]*)" are:$/) do |name, expected_table|
  world_location = WorldLocation.find_by!(name: name)
  visit world_location_path(world_location)
  rows = find(featured_documents_selector).all(".feature")
  table = rows.collect do |row|
    [
      row.find("h3").text.strip,
      File.basename(row.find(".gem-c-image-card__image")["src"]),
    ]
  end
  expected_table.diff!(table)
  expected_table.diff!(table)
end

Then(/^I should see a (?:world location|international delegation) called "([^"]*)"$/) do |name|
  expect(page).to have_selector(".world_location", text: name)
end

Then(/^I should not see a link to the (?:world location|international delegation) called "([^"]*)"$/) do |text|
  expect(page).to_not have_selector(".world_location a", text: text)
end

Then(/^I should see that it is an? (world location|international delegation)$/) do |world_location_type|
  expect(page).to have_selector(".type", text: world_location_type.capitalize)
end

def view_world_location_in_locale(world_location_name, locale)
  world_location = WorldLocation.find_by!(name: world_location_name)
  visit world_location_path(world_location)
  click_link locale
end

Then(/^when viewing the (?:world location|international delegation) "([^"]*)" with the locale "([^"]*)" I should see:$/) do |world_location_name, locale, table|
  view_world_location_in_locale(world_location_name, locale)
  translation = table.rows_hash
  expect(page).to have_selector("h1", text: translation["title"])
  expect(page).to have_selector(".mission_statement", text: translation["mission_statement"])
end

Then(/^I should be able to associate "([^"]+)" with the (?:world location|international delegation) "([^"]+)"$/) do |title, location|
  begin_editing_document title
  select location, from: "edition_world_location_ids"
  click_on "Save"
end

When(/^I click through to see all the announcements for (?:international delegation|world location) "([^"]*)"$/) do |name|
  visit world_location_path(WorldLocation.find_by!(name: name))
  within "#announcements" do
    click_link "See all"
  end
end

Given(/^an english news article called "([^"]*)" related to the (world location|international delegation)$/) do |title|
  world_location = WorldLocation.last
  create(:published_news_article, title: title, world_locations: [world_location])
end

When(/^I feature "([^"]*)" on the english "([^"]*)" page$/) do |title, overseas_territory_name|
  feature_news_article_in_world_location(title, overseas_territory_name)
end

When(/^I stop featuring the offsite link "(.*?)" for the (?:world location|international delegation) "(.*?)"$/) do |offsite_link_name, world_location_name|
  world_location = WorldLocation.find_by!(name: world_location_name)
  visit features_admin_world_location_news_path(world_location)
  offsite_link = OffsiteLink.find_by!(title: offsite_link_name)
  within record_css_selector(offsite_link) do
    click_on "Unfeature"
  end
end

Then(/^I should see the edit offsite link "(.*?)" on the "(.*?)" (?:world location|international delegation) page$/) do |title, world_location_name|
  world_location = WorldLocation.find_by!(name: world_location_name)
  offsite_link = OffsiteLink.find_by!(title: title)
  visit features_admin_world_location_news_path(world_location)
  expect(page).to have_link(title, href: edit_admin_world_location_news_offsite_link_path(world_location.slug, offsite_link.id))
end

Then(/^I should see "([^"]*)" featured on the public facing "([^"]*)" page$/) do |expected_title, name|
  visit world_location_path(WorldLocation.find_by!(name: name))
  expect(page).to have_selector(".feature h2", text: expected_title)
end

Then(/^there should be nothing featured on the home page of (?:world location|international delegation) "(.*?)"$/) do |name|
  visit world_location_path(name)
  rows = find(featured_documents_selector).all(".feature")
  expect(rows).to be_empty
end

Then(/^I should see the following world locations grouped under "(.*?)" in order:$/) do |letter, ordered_locations|
  within :xpath, ".//*#{xpath_class_selector('world-locations')}//*#{xpath_class_selector('js-filter-block')}[./h3[text()='#{letter}']]" do
    expect(ordered_locations.raw.map(&:first)).to eq(all(".world_location").map(&:text))
  end
end

Then(/^I should see the following international delegations in order:$/) do |ordered_delegations|
  within :xpath, ".//*#{xpath_class_selector('world-locations')}//section[@id='international-delegations']" do
    expect(ordered_delegations.raw.map(&:first)).to eq(all(".world_location").map(&:text))
  end
end
