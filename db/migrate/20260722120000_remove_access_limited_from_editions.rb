class RemoveAccessLimitedFromEditions < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :editions, :access_limited, :boolean, default: false, null: false }
  end
end
