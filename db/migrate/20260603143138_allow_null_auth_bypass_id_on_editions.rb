class AllowNullAuthBypassIdOnEditions < ActiveRecord::Migration[8.1]
  def up
    change_column_null :editions, :auth_bypass_id, true
  end

  def down
    # Editions can have a null auth_bypass_id once token generation is opt-in,
    # so backfill them before restoring the NOT NULL constraint.
    #
    # These backfilled UUIDs are written to the database only; they are not
    # propagated to the Publishing API / Content Store. Any backfilled edition
    # must be republished manually for its token to take effect - until then
    # the preview link shown on its summary page will return a 403.
    execute "UPDATE editions SET auth_bypass_id = UUID() WHERE auth_bypass_id IS NULL"
    change_column_null :editions, :auth_bypass_id, false
  end
end
