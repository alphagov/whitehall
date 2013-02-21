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
