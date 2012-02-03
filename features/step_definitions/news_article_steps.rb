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
  create(:featured_news_article, title: title)
end

Given /^(\d+) published featured news articles$/ do |number|
  number.to_i.times { create(:featured_news_article) }
end

When /^I visit the news and speeches page$/ do
  visit announcements_path
end

When /^I draft a new news article "([^"]*)"$/ do |title|
  begin_drafting_document type: "news_article", title: title
  fill_in "Summary", with: "here's a simple summary"
  attach_file "Image", Rails.root.join("features/fixtures/portas-review.jpg")
  fill_in "Alt text", with: 'An alternative description'
  click_button "Save"
end

When /^I draft a new news article "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "News Article", title: title
  select first_policy, from: "Related Policies"
  select second_policy, from: "Related Policies"
  click_button "Save"
end

When /^I feature the news article "([^"]*)"$/ do |title|
  news_article = NewsArticle.find_by_title!(title)
  visit published_admin_documents_path(filter: 'news_article')
  within record_css_selector(news_article) do
    image = jpg_image
    attach_file "Featuring image", image.path
    click_button "Feature"
  end
end

When /^I unfeature the news article "([^"]*)"$/ do |title|
  news_article = NewsArticle.find_by_title!(title)
  visit published_admin_documents_path(filter: 'news_article')
  within record_css_selector(news_article) do
    click_button "No longer feature"
  end
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

Then /^the news article "([^"]*)" should (not )?be featured on the public news and speeches page$/ do |title, should_not_be_featured|
  visit announcements_path
  news_article = NewsArticle.published.find_by_title!(title)

  news_article_is_featured = has_css?("#featured-news-articles #{record_css_selector(news_article)}")
  if should_not_be_featured
    refute news_article_is_featured
  else
    assert news_article_is_featured
  end
end
