class AddDisabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :disabled, :boolean, default: false
    add_index :users, :disabled
  end
end
