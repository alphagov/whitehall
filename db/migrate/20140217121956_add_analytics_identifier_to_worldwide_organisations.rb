class AddAnalyticsIdentifierToWorldwideOrganisations < ActiveRecord::Migration
  def change
    add_column :worldwide_organisations, :analytics_identifier, :string
  end

  def migrate(direction)
    super

    if direction == :up
      WorldwideOrganisation.all.each do |organisation|
        organisation.update_column :analytics_identifier, WorldwideOrganisation.analytics_prefix + organisation.id.to_s
      end
    end
  end
end
