Given /^a published news article "([^"]*)" with related published policies "([^"]*)" and "([^"]*)"$/ do |news_article_title, policy_title_1, policy_title_2|
  policy_1 = create(:published_policy, title: policy_title_1)
  policy_2 = create(:published_policy, title: policy_title_2)
  create(:published_news_article, title: news_article_title, documents_related_to: [policy_1, policy_2])
end

Given /^a published news article "([^"]*)" exists relating to the country "([^"]*)"$/ do |title, country_name|
  country = Country.find_by_name!(country_name)
  create(:published_news_article, title: title, countries: [country])
end

Given /^a published news article "([^"]*)" with editorial guidance "([^"]*)"$/ do |title, editorial_guidance|
  create(:published_news_article, title: title, editorial_guidance: editorial_guidance)
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

Then /^I should see the editorial guidance "([^"]*)" for the news article$/ do |editorial_guidance|
  assert has_css?(".editorial_guidance", text: editorial_guidance)
end