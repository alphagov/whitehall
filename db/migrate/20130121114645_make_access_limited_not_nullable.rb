class MakeAccessLimitedNotNullable < ActiveRecord::Migration
  def up
    change_column_null(:editions, :access_limited, false, false)
  end

  def down
    change_column_null(:editions, :access_limited, true)
  end
end
