class AddHandlesFatalitiesToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :handles_fatalities, :boolean, default: false
    # We hardcode this here rather than go through the palava of a seperate data migration
    # Can always be tweaked later as needed
    execute("UPDATE organisations SET handles_fatalities = true WHERE slug = 'ministry-of-defence'")
  end
end
