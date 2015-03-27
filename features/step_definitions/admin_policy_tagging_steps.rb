Then(/^I can tag it to some policies$/) do
  tag_to_policies(policies: [policy_1])
  check_edition_is_tagged_to_policies(edition: Publication.last, policies: [policy_1])
end
