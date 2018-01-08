class CreateJoinTableStatisticsAnnouncementOrganisation < ActiveRecord::Migration
  def up
    create_table :statistics_announcement_organisations, id: false do |t|
      t.references :statistics_announcement
      t.references :organisation
      t.timestamps
    end

    add_index :statistics_announcement_organisations, :organisation_id
    add_index :statistics_announcement_organisations,
      %i[statistics_announcement_id organisation_id],
      name: :index_on_statistics_announcement_id_and_organisation_id
      # rails generated name is longer than 64 characters, hence not supported
  end

  def down
    remove_index :statistics_announcement_organisations, :organisation_id
    remove_index :statistics_announcement_organisations,
      name: :index_on_statistics_announcement_id_and_organisation_id
    drop_table :statistics_announcement_organisations
  end
end
