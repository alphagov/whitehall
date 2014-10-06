class DropOrganisationIdFromStatisticsAnnouncements < ActiveRecord::Migration
  def up
    remove_column :statistics_announcements, :organisation_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
