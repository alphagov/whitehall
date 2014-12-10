class AddIdToStatisticsAnnouncementOrganisations < ActiveRecord::Migration
  def change
    add_column :statistics_announcement_organisations, :id, :primary_key
  end
end
