class DropEditionRelationships < ActiveRecord::Migration[8.0]
  def change
    drop_table :edition_relationships, if_exists: true
  end
end
