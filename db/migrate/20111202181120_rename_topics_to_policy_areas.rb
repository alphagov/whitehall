class RenameTopicsToPolicyAreas < ActiveRecord::Migration
  def change
    rename_table :topics, :policy_areas
    rename_index :policy_areas, "index_topics_on_slug", "index_policy_areas_on_slug"
    rename_table :document_topics, :document_policy_areas
    rename_column :document_policy_areas, :topic_id, :policy_area_id
  end
end