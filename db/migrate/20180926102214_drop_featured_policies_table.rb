class DropFeaturedPoliciesTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :featured_policies
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
