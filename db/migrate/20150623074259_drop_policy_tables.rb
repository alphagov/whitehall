class DropPolicyTables < ActiveRecord::Migration
  def up
    drop_table :edition_policy_groups
    drop_table :editioned_supporting_page_mappings
    drop_table :featured_items
    drop_table :featured_topics_and_policies_lists
    drop_table :supporting_page_redirects
  end
end
