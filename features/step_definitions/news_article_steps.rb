Given /^a published news article "([^"]*)" with related published policies "([^"]*)" and "([^"]*)"$/ do |news_article_title, policy_title_1, policy_title_2|
  policy_1 = create(:published_policy, title: policy_title_1)
  policy_2 = create(:published_policy, title: policy_title_2)
  create(:published_news_article, title: news_article_title, related_policies: [policy_1, policy_2])
end

Given /^a published news article "([^"]*)" with notes to editors "([^"]*)"$/ do |title, notes_to_editors|
  create(:published_news_article, title: title, notes_to_editors: notes_to_editors)
end

Given /^a published news article "([^"]*)" for the organisation "([^"]*)"$/ do |title, organisation|
  organisation = create(:organisation, name: organisation)
  create(:published_news_article, title: title, organisations: [organisation])
end

Given /^a published news article "([^"]*)" for the policy "([^"]*)"$/ do |title, policy_name|
  policy = Policy.find_by_title(policy_name) || create(:policy, title: policy_name)
  create(:published_news_article, title: title, related_policies: [policy])
end

When /^I draft a new news article "([^"]*)"$/ do |title|
  begin_drafting_document type: "news_article", title: title
  fill_in "Summary", with: "here's a simple summary"
  within ".images" do
    attach_file "File", Rails.root.join("features/fixtures/portas-review.jpg")
    fill_in "Alt text", with: 'An alternative description'
  end
  click_button "Save"
end

When /^I draft a new news article "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "News Article", title: title
  select first_policy, from: "Related policies"
  select second_policy, from: "Related policies"
  click_button "Save"
end

Then /^I should see the notes to editors "([^"]*)" for the news article$/ do |notes_to_editors|
  assert has_css?("#{notes_to_editors_selector}", text: notes_to_editors)
end
