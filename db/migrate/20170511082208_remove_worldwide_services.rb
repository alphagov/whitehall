class RemoveWorldwideServices < ActiveRecord::Migration
  def change
    drop_table :worldwide_office_worldwide_services
    drop_table :worldwide_services
  end
end
