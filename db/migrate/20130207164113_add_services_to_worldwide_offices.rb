class AddServicesToWorldwideOffices < ActiveRecord::Migration
  def change
    add_column :worldwide_offices, :services, :text
  end
end
