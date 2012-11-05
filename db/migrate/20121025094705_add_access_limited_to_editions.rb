class AddAccessLimitedToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :access_limited, :boolean
  end
end
