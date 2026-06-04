class DefaultAccessLimitedToFalse < ActiveRecord::Migration[8.1]
  def change
    change_column_default :editions, :access_limited, from: nil, to: false
  end
end
