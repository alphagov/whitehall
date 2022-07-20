When(/^I (?:also )?filter by (only )?a keyword$/) do |only|
  fill_in_filter "Contains", "keyword", only.present?
end

When(/^I (?:also )?filter by (only )?a publication type$/) do |only|
  select_filter "Publication type", "Guidance", only.present?
end

When(/^I (?:also )?filter by (only )?a topic$/) do |only|
  select_filter "Topic", "A Topic", only.present?
end

When(/^I (?:also )?filter by (only )?a department$/) do |only|
  select_filter "Department", "A Department", only.present?
end

When(/^I (?:also )?filter by (only )?a world location$/) do |only|
  select_filter "World locations", "A World Location", only.present?
end

When(/^I (?:also )?filter by (only )?published date$/) do |only|
  clear_filters if only.present?
  fill_in "Published after", with: "01/01/2013"
  fill_in "Published before", with: "01/03/2013"
  click_on "Refresh results"
end

### Announcements

Given(/^there are some published announcments including a few in French$/) do
  create :published_news_story, title: "News Article in English only"
  uk_world_location = create(:world_location, name: "United Kingdom")
  I18n.with_locale :fr do
    create :published_news_story, :translated, title: "C'est la vie"
    create :published_news_story, :translated, title: "À propos du Royaume-Uni", world_locations: [uk_world_location]
  end
end

When(/^I visit the announcments index in French$/) do
  stub_content_item_from_content_store_for(announcements_path)
  visit "#{announcements_path}.fr"
end

Then(/^I should see only announcements which have French translations$/) do
  expect(page).to have_content("C'est la vie")
  expect(page).to have_content("À propos du Royaume-Uni")
  expect(page).to_not have_content("News Article in English only")
end

When(/^I filter them by world location \(or 'Emplacements dans le monde' in French\)$/) do
  select "United Kingdom", from: "Emplacements dans le monde"
end

Then(/^I should see only French announcements associated with the world location$/) do
  expect(page).to have_content("À propos du Royaume-Uni")
  # using to have_no_content over to_not have_content as the former will wait for content to disappear
  expect(page).to have_no_content("C'est la vie")
end
