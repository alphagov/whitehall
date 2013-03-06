Given /^a world location news article "([^"]+)" exists$/ do |title|
  create(:published_world_location_news_article, title: title)
end

Given /^a world location news article "([^"]+)" for the world location "([^"]+)" exists$/ do |title, location|
  world_location = create(:world_location)
  create(:published_world_location_news_article, title: title, world_locations: [world_location])
end

When /^I create a valid world location news article "([^"]*)"$/ do |title|
  begin_drafting_world_location_news_article title: title, body: 'test-body', summary: 'test-summary'
  click_button "Save"
end

Then /^I should not be able to see a world location news article "([^"]+)"$/ do |title|
  article = WorldLocationNewsArticle.find_by_title(title)
  refute record_css_selector(article), "Can see \"#{article.title}\" when I shouldn't be able to"
end

Then /^I should see the world location news article "([^"]*)"$/ do |title|
  article = WorldLocationNewsArticle.find_by_title(title)
  assert record_css_selector(article), "Can't see \"#{article.title}\" when I should be able to"
end

Then /^the world location news article "([^"]*)" should have been created$/ do |title|
  WorldLocationNewsArticle.find_by_title(title).should_not be_nil
end

Then /^the worldwide organisation "([^"]+)" is listed as a producing org on the world location news article "([^"]+)"$/ do |world_org_name, world_news_title|
  visit document_path(WorldLocationNewsArticle.find_by_title(world_news_title))
  world_org = WorldwideOrganisation.find_by_name(world_org_name)
  within '.meta .organisations-icon-list' do
    assert page.has_link?(world_org.name, href: worldwide_organisation_path(world_org)), "should have a link to #{world_org.name} as a producing org, but I don't"
  end
end

Then /^see the world location news article "([^"]+)" appear on the worldwide priority "([^"]+)"$/ do |world_news_title, world_priority_title|
  visit worldwide_priority_path(WorldwidePriority.find_by_title(world_priority_title))
  world_news_article = WorldLocationNewsArticle.find_by_title(world_news_title)
  assert record_css_selector(world_news_article) do
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
  check 'Include location-specific news'
  click_on "Refresh results"
end

Then /^I should be able to see the world location news article$/ do
  assert page.has_css?(record_css_selector(@world_location_news))
end
