class AddAccessLimitingToEditions < ActiveRecord::Migration[8.1]
  def change
    add_column :editions, :access_limiting, :string, default: "none", null: false
  end
end
