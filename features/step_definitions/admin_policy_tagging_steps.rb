Then(/^I can tag the edition to some policies$/) do
  tag_to_policies(policies: [policy_1])
  check_edition_is_tagged_to_policies(edition: Publication.last, policies: [policy_1])
end

Then(/^I can tag the topic to some policies$/) do
  tag_to_policies(policies: [policy_1])
  check_topic_is_tagged_to_policies(topic: Topic.last, policies: [policy_1])
end
