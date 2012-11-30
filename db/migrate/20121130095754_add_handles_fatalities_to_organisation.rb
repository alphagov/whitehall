class AddHandlesFatalitiesToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :handles_fatalities, :boolean, default: false
    execute("UPDATE organisations SET handles_fatalities = true WHERE slug = 'ministry-of-defence'")
  end
end
