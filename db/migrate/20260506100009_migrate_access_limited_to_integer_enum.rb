class MigrateAccessLimitedToIntegerEnum < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      change_column :editions, :access_limited, :integer, null: false, default: 0
    end
  end

  def down
    safety_assured do
      change_column :editions, :access_limited, :boolean, null: false
    end
  end
end
