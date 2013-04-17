class CreateHistoricalAccountRoles < ActiveRecord::Migration
  def change
    create_table :historical_account_roles do |t|
      t.references :role
      t.references :historical_account

      t.timestamps
    end
    add_index :historical_account_roles, :role_id
    add_index :historical_account_roles, :historical_account_id
  end
end
