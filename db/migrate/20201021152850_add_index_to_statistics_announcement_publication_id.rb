class AddIndexToStatisticsAnnouncementPublicationId < ActiveRecord::Migration[5.1]
  def change
    change_table :statistics_announcements, bulk: true do |t|
      t.remove_index name: "index_statistics_announcements_on_publication_id", column: :publication_id
      t.index :publication_id, unique: true
    end
  end
end
