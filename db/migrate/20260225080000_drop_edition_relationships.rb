class DropEditionRelationships < ActiveRecord::Migration[8.0]
  def up
    drop_table :edition_relationships, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end