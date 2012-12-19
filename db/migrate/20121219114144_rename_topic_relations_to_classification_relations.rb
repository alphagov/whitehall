class RenameTopicRelationsToClassificationRelations < ActiveRecord::Migration
  def up
    rename_table :topic_relations, :classification_relations

    rename_index :classification_relations, "index_policy_topic_relations_on_related_policy_topic_id", "index_classification_relations_on_related_classification_id"
    rename_index :classification_relations, "index_policy_topic_relations_on_policy_topic_id", "index_classification_relations_on_classification_id"
  end
end
