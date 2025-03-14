class DropEditionPoliciesTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :edition_policies
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
