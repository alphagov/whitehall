Given(/^a publicationesque that can be assigned to policies and topics$/) do
  @edition = create(:draft_publication)
  @topic = create(:topic)
end

When(/^I assign the publicationesque to a topic$/) do
  visit edit_admin_publication_path(@edition)
  select @topic.name, from: 'edition_topic_ids'
  click_button 'Save'
end

Then(/^the edition will be assigned to the topic$/) do
  assert @edition.topics.include?(@topic)
end

Given(/^an announcement that can be assigned to policies and topics$/) do
  @edition = create(:draft_news_article)
  @topic = create(:topic)
  @policy = create(:policy, topics: [@topic])
end

When(/^I assign the announcement to a policy with topics$/) do
  visit edit_admin_news_article_path(@edition)
  select @policy.title, from: 'edition_related_policy_ids'
end

Then(/^the policy's topics will be copied from the policy to the announcement$/) do
  assert page.has_css?('li.search-choice span', text: /^#{@topic.name}$/)
  click_button 'Save'
end
