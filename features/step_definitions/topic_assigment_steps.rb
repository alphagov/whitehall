Given(/^a publicationesque that can be assigned to policies and topics$/) do
  @edition = create(:draft_publication)
  @topic = create(:topic)
end

When(/^I assign the publicationesque to a topic$/) do
  visit edit_admin_publication_path(@edition)
  select_from_chzn('edition_topic_ids', @topic.name)
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
  select_from_chzn('edition_related_policy_ids', @policy.title)
end

Then(/^the policy's topics will be copied from the policy to the announcement$/) do
  assert page.has_css?('li.search-choice span', text: /^#{@topic.name}$/)
  click_button 'Save'
end
