class AuthBypassIdNotNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :editions, :auth_bypass_id, false
  end
end
