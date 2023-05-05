class AddDefaultAccessAndOpeningTimesToWorldwideOrganisation < ActiveRecord::Migration[7.0]
  def change
    add_column :worldwide_organisations, :default_access_and_opening_times, :text
  end
end
