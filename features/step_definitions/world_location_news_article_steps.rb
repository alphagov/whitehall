Given /^a world location news article "([^"]+)" exists$/ do |title|
  create(:published_world_location_news_article, title: title)
end

Given /^a world location news article "([^"]+)" for the world location "([^"]+)" exists$/ do |title, location|
  world_location = create(:world_location)
  worldwide_organisation = create(:worldwide_organisation)
  create(:published_world_location_news_article, title: title, world_locations: [world_location], worldwide_organisations: [worldwide_organisation])
end

When /^I draft a valid world location news article "([^"]*)"$/ do |title|
  world_location = create(:world_location, name: "Afganistan")
  worldwide_organisation = create(:worldwide_organisation, name: "Afganistan embassy")

  begin_drafting_world_location_news_article title: title, body: 'test-body', summary: 'test-summary'

  select "Afganistan", from: "Select the world locations this world location news article is about"
  select "Afganistan embassy", from: "Select the worldwide organisations associated with this world location news article"

  click_button "Save"
end

Then /^the world location news article "([^"]*)" should have been created$/ do |title|
  refute WorldLocationNewsArticle.find_by_title(title).nil?
end

Then /^the worldwide organisation "([^"]+)" is listed as a producing org on the world location news article "([^"]+)"$/ do |world_org_name, world_news_title|
  visit document_path(WorldLocationNewsArticle.find_by_title(world_news_title))
  world_org = WorldwideOrganisation.find_by_name(world_org_name)
  within '.meta' do
    assert page.has_link?(world_org.name, href: worldwide_organisation_path(world_org)), "should have a link to #{world_org.name} as a producing org, but I don't"
  end
end

Then /^the world location news article "([^"]+)" appears on the worldwide priority "([^"]+)"$/ do |world_news_title, world_priority_title|
  visit document_path(WorldwidePriority.find_by_title(world_priority_title))
  world_news_article = WorldLocationNewsArticle.find_by_title(world_news_title)
  within record_css_selector(world_news_article, 'recent') do
    assert page.has_content?(world_news_article.title)
  end
end

Then /^the world location news article "([^"]+)" appears on the world location "([^"]+)"$/ do |world_news_title, world_location_name|
  visit world_location_path(WorldLocation.find_by_name(world_location_name))
  world_news_article = WorldLocationNewsArticle.find_by_title(world_news_title)
  within record_css_selector(world_news_article) do
    assert page.has_content?(world_news_article.title)
  end
end

Given /^there is a world location news article$/ do
  @world_location_news = create(:published_world_location_news_article)
end

Then /^I should not be able to see the world location news article$/ do
  refute page.has_css?(record_css_selector(@world_location_news))
end

When /^I explicitly ask for world location news to be included$/ do
  visit announcements_path
  check 'Include local news from UK embassies and other world organisations'
  click_on "Refresh results"
end

Then /^I should be able to see the world location news article$/ do
  assert page.has_css?(record_css_selector(@world_location_news))
end
