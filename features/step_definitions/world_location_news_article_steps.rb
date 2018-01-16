# encoding: utf-8

Then(/^I should see the world location news article listed in admin with an indication that it is in French$/) do
  assert_path admin_edition_path(@world_location_news_article)
  assert page.has_content?("This document is French-only")
end

Then(/^I should only see the world location news article on the French version of the public "([^"]*)" location page$/) do |world_location_name|
  world_location = WorldLocation.find_by!(name: world_location_name)
  visit world_location_path(world_location, locale: :fr)
  within record_css_selector(@world_location_news_article) do
    assert page.has_content?(@world_location_news_article.title)
  end

  visit world_location_path(world_location)
  assert page.has_no_css?(record_css_selector(@world_location_news_article))
end

Then(/^I should only be able to view the world location news article article in French$/) do
  visit world_location_news_article_path(@world_location_news_article.document, locale: :fr)
  assert page.has_content?(@world_location_news_article.title)

  visit world_location_news_article_path(@world_location_news_article.document, locale: :en)
  assert_equal 404, page.status_code
end

When(/^I draft a valid world location news article "([^"]*)"$/) do |title|
  create(:world_location, name: "Afghanistan", active: true)
  create(:worldwide_organisation, name: "Afghanistan embassy")

  begin_drafting_world_location_news_article title: title, body: 'test-body', summary: 'test-summary'

  select "Afghanistan", from: "Select the world locations this world location news article is about"
  select "Afghanistan embassy", from: "Select the worldwide organisations associated with this world location news article"

  click_button "Save"
end

Then(/^the world location news article "([^"]*)" should have been created$/) do |title|
  refute WorldLocationNewsArticle.find_by(title: title).nil?
end

Then(/^the worldwide organisation "([^"]+)" is listed as a producing org on the world location news article "([^"]+)"$/) do |world_org_name, world_news_title|
  visit document_path(WorldLocationNewsArticle.find_by(title: world_news_title))
  world_org = WorldwideOrganisation.find_by(name: world_org_name)
  within '.meta' do
    assert page.has_link?(world_org.name, href: worldwide_organisation_path(world_org)), "should have a link to #{world_org.name} as a producing org, but I don't"
  end
end

Then(/^the topical event "([^"]+)" is listed as a topical event on the world location news article "([^"]+)"$/) do |topical_event_name, world_news_title|
  visit document_path(WorldLocationNewsArticle.find_by(title: world_news_title))
  topical_event = TopicalEvent.find_by(name: topical_event_name)
  within '.meta' do
    assert page.has_link?(topical_event.name, href: topical_event_path(topical_event)), "should have a link to #{topical_event.name} as a topical event, but I don't"
  end
end

Then(/^the world location news article "([^"]+)" appears on the (?:world location|international delegation) "([^"]+)"$/) do |world_news_title, world_location_name|
  visit world_location_path(WorldLocation.find_by(name: world_location_name))
  world_location_news_article = WorldLocationNewsArticle.find_by(title: world_news_title)
  within record_css_selector(world_location_news_article) do
    assert page.has_content?(world_location_news_article.title)
  end
end

Given(/^there is a world location news article$/) do
  @world_location_news = create(:published_world_location_news_article)
end

Then(/^I should not be able to see the world location news article$/) do
  assert page.has_no_css?(record_css_selector(@world_location_news))
end

When(/^I explicitly ask for world location news to be included$/) do
  visit announcements_path
  check 'Include local news from UK embassies and other world organisations'
  click_on "Refresh results"
end

Then(/^I should be able to see the world location news article$/) do
  assert page.has_css?(record_css_selector(@world_location_news))
end

Given(/^a draft right\-to\-left non\-English edition exists$/) do
  I18n.with_locale(:ar) do
    @edition = create(:world_location_news_article, title: 'Arabic title', body: 'Arabic body', summary: 'Arabic summary', primary_locale: :ar)
  end
end

When(/^I edit the right\-to\-left non\-English edition$/) do
  ensure_path edit_admin_edition_path(@edition)
end

Then(/^I should see that the form text fields are displayed right to left$/) do
  assert page.has_css?('form fieldset.right-to-left')
end
