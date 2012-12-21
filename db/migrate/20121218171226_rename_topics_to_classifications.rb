class RenameTopicsToClassifications < ActiveRecord::Migration
  def up
    rename_table :topics, :classifications
    rename_index :classifications, "index_policy_areas_on_slug", "index_classifications_on_slug"

    add_column :classifications, :type, :string
    execute "update classifications set type='Topic'"

    rename_column :topic_memberships, :topic_id, :classification_id
    rename_column :organisation_topics, :topic_id, :classification_id
    rename_column :topic_relations, :topic_id, :classification_id
    rename_column :topic_relations, :related_topic_id, :related_classification_id
  end

  def down
    rename_column :topic_memberships, :classification_id, :topic_id
    rename_column :organisation_topics, :classification_id, :topic_id
    rename_column :topic_relations, :classification_id, :topic_id
    rename_column :topic_relations, :related_classification_id, :related_topic_id

    remove_column :classifications, :type
    rename_index :classifications, "index_classifications_on_slug", "index_policy_areas_on_slug"
    rename_table :classifications, :topics
  end
end
