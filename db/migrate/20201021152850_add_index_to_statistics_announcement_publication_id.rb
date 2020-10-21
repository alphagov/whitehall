class AddIndexToStatisticsAnnouncementPublicationId < ActiveRecord::Migration[5.1]
  def change
    # rubocop:disable Rails/BulkChangeTable
    remove_index :statistics_announcements, name: "index_statistics_announcements_on_publication_id", column: :publication_id
    add_index :statistics_announcements, :publication_id, unique: true
    # rubocop:enable Rails/BulkChangeTable
  end
end
