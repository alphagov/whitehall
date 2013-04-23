class AddSupportsHistoricalAccountsToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :supports_historical_accounts, :boolean, default: false, null: false
    add_index :roles, :supports_historical_accounts
  end
end
