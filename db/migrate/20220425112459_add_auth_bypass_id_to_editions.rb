class AddAuthBypassIdToEditions < ActiveRecord::Migration[7.0]
  def change
    add_column :editions, :auth_bypass_id, :string
  end
end
