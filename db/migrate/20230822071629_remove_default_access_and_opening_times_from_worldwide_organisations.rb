class RemoveDefaultAccessAndOpeningTimesFromWorldwideOrganisations < ActiveRecord::Migration[7.0]
  def change
    remove_column :worldwide_organisations, :default_access_and_opening_times, :text
  end
end
