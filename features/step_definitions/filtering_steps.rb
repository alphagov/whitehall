
When(/^I (?:also )?filter by (only )?a keyword$/) do |only|
  fill_in_filter "Contains", "keyword", !!only
end

When(/^I (?:also )?filter by (only )?a publication type$/) do |only|
  select_filter "Publication type", "Guidance", !!only
end

When(/^I (?:also )?filter by (only )?a topic$/) do |only|
  select_filter "Topic", "A Topic", !!only
end

When(/^I (?:also )?filter by (only )?a department$/) do |only|
  select_filter "Department", "A Department", !!only
end

When(/^I (?:also )?filter by (only )?a world location$/) do |only|
  select_filter "World locations", "A World Location", !!only
end

When(/^I (?:also )?filter by (only )?published date$/) do |only|
  if only
    clear_filters
  end
  page.fill_in "Published after", with: "01/01/2013"
  page.fill_in "Published before", with: "01/03/2013"
  page.click_on "Refresh results"
end

### Announcements

Given(/^there are some published announcments including a few in French$/) do
  create :published_news_story, title: "News Article in English only"
  I18n.with_locale :fr do
    create :published_news_story, :translated, title: "C'est la vie"
  end
end

When(/^I visit the announcments index in French$/) do
  stub_content_item_from_content_store_for(announcements_path)
  visit announcements_path + '.fr'
end

Then(/^I should see only announcements which have French translations$/) do
  assert page.has_content? "C'est la vie"
  assert page.has_no_content? "News Article in English only"
end

Then(/^I should be able to filter them by country \(or 'Pays' in French\)$/) do
  within '#document-filter' do
    assert page.has_selector?('label', count: 1)
    assert page.has_content?("Pays")
  end
end
