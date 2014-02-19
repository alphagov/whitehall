class AddAnalyticsIdentifierToWorldwideOrganisations < ActiveRecord::Migration
  def change
    add_column :worldwide_organisations, :analytics_identifier, :string
  end
end
