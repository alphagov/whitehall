When /^I draft a new news article "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "News Article", title: title
  select first_policy, from: "Related Policies"
  select second_policy, from: "Related Policies"
  click_button "Save"
end

Then /^I can see links to the related published news articles "([^"]*)" and "([^"]*)"$/ do |news_article_title_1, news_article_title_2|
  news_article_1 = NewsArticle.published.find_by_title(news_article_title_1)
  news_article_2 = NewsArticle.published.find_by_title(news_article_title_2)
  assert has_css?("#related-news-articles .news_article a", text: news_article_title_1)
  assert has_css?("#related-news-articles .news_article a", text: news_article_title_2)
end