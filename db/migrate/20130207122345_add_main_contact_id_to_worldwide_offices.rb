class AddMainContactIdToWorldwideOffices < ActiveRecord::Migration
  def change
    add_column :worldwide_offices, :main_contact_id, :integer
  end
end
