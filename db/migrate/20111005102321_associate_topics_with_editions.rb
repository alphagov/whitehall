class AssociateTopicsWithEditions < ActiveRecord::Migration
  def change
    remove_column :document_topics, :document_id
    rename_table :document_topics, :edition_topics
    add_column :edition_topics, :edition_id, :integer
  end
end
