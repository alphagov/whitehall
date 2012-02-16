class RenamePolicyAreasToPolicyTopics < ActiveRecord::Migration
  def change
    rename_column "organisation_policy_areas", "policy_area_id", "policy_topic_id"
    rename_table  "organisation_policy_areas", "organisation_policy_topics"

    rename_column "policy_area_memberships", "policy_area_id", "policy_topic_id"
    rename_table  "policy_area_memberships", "policy_topic_memberships"

    rename_column "policy_area_relations", "policy_area_id", "policy_topic_id"
    rename_column "policy_area_relations", "related_policy_area_id", "related_policy_topic_id"
    rename_table  "policy_area_relations", "policy_topic_relations"

    rename_table  "policy_areas", "policy_topics"
  end
end
