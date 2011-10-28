When /^I draft a new news article "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "News Article", title: title
  select first_policy, from: "Related Policies"
  select second_policy, from: "Related Policies"
  click_button "Save"
end

Then /^I can visit the published news article "([^"]*)" from the "([^"]*)" policy$/ do |news_article_title, policy_title|
  policy = Policy.find_by_title(policy_title)
  visit public_document_path(policy)
  assert has_css?("#related-news-articles .news_article a", text: news_article_title)
  click_link news_article_title
  assert has_css?(".title", text: news_article_title)
end