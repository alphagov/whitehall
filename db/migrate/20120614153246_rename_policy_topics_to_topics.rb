class RenamePolicyTopicsToTopics < ActiveRecord::Migration
  def change
    rename_column "organisation_policy_topics", "policy_topic_id", "topic_id"
    rename_table  "organisation_policy_topics", "organisation_topics"

    rename_column "policy_topic_memberships", "policy_topic_id", "topic_id"
    rename_table  "policy_topic_memberships", "topic_memberships"

    rename_column "policy_topic_relations", "policy_topic_id", "topic_id"
    rename_column "policy_topic_relations", "related_policy_topic_id", "related_topic_id"
    rename_table  "policy_topic_relations", "topic_relations"

    rename_table  "policy_topics", "topics"
  end
end
