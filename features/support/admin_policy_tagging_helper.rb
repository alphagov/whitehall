module AdminPolicyTaggingHelper
  def tag_to_policies(policies:)
    policies.each do |policy|
      select policy["title"], from: "Policies"
      click_button "Save"
    end
  end

  def check_edition_is_tagged_to_policies(edition:, policies: [])
    assert_path admin_publication_path(edition)
    policy_content_ids = policies.map { |policy| policy["content_id"] }
    assert_equal policy_content_ids, edition.policy_content_ids
  end

  def check_topic_is_tagged_to_policies(topic:, policies: [])
    assert_path admin_topic_path(topic)
    policy_content_ids = policies.map { |policy| policy["content_id"] }
    assert_equal policy_content_ids, topic.policy_content_ids
  end
end

World(AdminPolicyTaggingHelper)
