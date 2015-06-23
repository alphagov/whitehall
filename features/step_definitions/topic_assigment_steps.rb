Given(/^a publicationesque that can be assigned to policies and policy areas$/) do
  @edition = create(:draft_publication)
  @topic = create(:topic)
end

When(/^I assign the publicationesque to a policy area$/) do
  visit edit_admin_publication_path(@edition)
  select @topic.name, from: 'edition_topic_ids'
  click_button 'Save'
end

Then(/^the edition will be assigned to the policy area$/) do
  assert @edition.topics.include?(@topic)
end

Given(/^an announcement that can be assigned to policies and policy areas$/) do
  @edition = create(:draft_news_article)
  @topic = create(:topic)
  stub_content_register_policies
end

When(/^I assign the announcement to a policy with policy areas$/) do
  visit edit_admin_news_article_path(@edition)
  select "Policy 1", from: 'edition_policy_content_ids'
end

Then(/^the policy's topics will be copied from the policy to the announcement$/) do
  assert page.has_css?('li.search-choice span', text: /^#{@topic.name}$/)
  click_button 'Save'
end
