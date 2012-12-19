class RenameTopicMembershipsToClassificationMemberships < ActiveRecord::Migration
  def change
    rename_table :topic_memberships, :classification_memberships

    rename_index :classification_memberships, "index_topic_memberships_on_topic_id", "index_classification_memberships_on_classification_id"
    rename_index :classification_memberships, "index_topic_memberships_on_edition_id", "index_classification_memberships_on_edition_id"
  end
end
