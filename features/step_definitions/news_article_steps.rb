Given /^a published news article "([^"]*)" with related published policies "([^"]*)" and "([^"]*)"$/ do |news_article_title, policy_title_1, policy_title_2|
  policy_1 = create(:published_policy, title: policy_title_1)
  policy_2 = create(:published_policy, title: policy_title_2)
  create(:published_news_article, title: news_article_title, related_policies: [policy_1, policy_2])
end

Given /^a published news article "([^"]*)" exists relating to the country "([^"]*)"$/ do |title, country_name|
  country = Country.find_by_name!(country_name)
  create(:published_news_article, title: title, countries: [country])
end

Given /^a published news article "([^"]*)" with notes to editors "([^"]*)"$/ do |title, notes_to_editors|
  create(:published_news_article, title: title, notes_to_editors: notes_to_editors)
end

Given /^a published featured news article "([^"]*)"$/ do |title|
  create(:published_news_article, title: title, featured: true)
end

Given /^(\d+) published featured news articles$/ do |number|
  number.to_i.times { create(:published_news_article, featured: true) }
end

When /^I visit the news and speeches page$/ do
  visit announcements_path
end

When /^I draft a new news article "([^"]*)"$/ do |title|
  begin_drafting_document type: "news_article", title: title
  fill_in "Summary", with: "here's a simple summary"
  click_button "Save"
end

When /^I draft a new news article "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "News Article", title: title
  select first_policy, from: "Related Policies"
  select second_policy, from: "Related Policies"
  click_button "Save"
end

Then /^I can see links to the related published news articles "([^"]*)" and "([^"]*)"$/ do |news_article_title_1, news_article_title_2|
  assert has_css?("#{related_news_articles_selector} .news_article a", text: news_article_title_1)
  assert has_css?("#{related_news_articles_selector} .news_article a", text: news_article_title_2)
end

Then /^I should see the notes to editors "([^"]*)" for the news article$/ do |notes_to_editors|
  assert has_css?("#{notes_to_editors_selector}", text: notes_to_editors)
end

Then /^I should see "([^"]*)" in the list of featured news articles$/ do |title|
  assert has_css?("#{featured_news_articles_selector} .news_article a", text: title)
end

Then /^I should only see the most recent (\d+) in the list of featured news articles$/ do |number|
  assert has_css?("#{featured_news_articles_selector} .news_article", count: number.to_i)
end