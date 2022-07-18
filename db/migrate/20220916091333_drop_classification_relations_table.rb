class DropClassificationRelationsTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :classification_relations
  end
end
