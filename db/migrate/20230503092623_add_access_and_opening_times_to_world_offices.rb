class AddAccessAndOpeningTimesToWorldOffices < ActiveRecord::Migration[7.0]
  def change
    add_column :worldwide_offices, :access_and_opening_times, :text
  end
end
