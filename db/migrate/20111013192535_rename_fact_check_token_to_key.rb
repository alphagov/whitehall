class RenameFactCheckTokenToKey < ActiveRecord::Migration
  def change
    rename_column :fact_check_requests, :token, :key
    add_index :fact_check_requests, :key, unique: true
  end
end
