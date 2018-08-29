class DropSyncCheckResult < ActiveRecord::Migration[5.1]
  def change
    drop_table :sync_check_results
  end
end
