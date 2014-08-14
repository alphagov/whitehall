class AddCancellationAttributesToStatisticsAnnouncement < ActiveRecord::Migration
  def change
    add_column :statistics_announcements, :cancellation_reason, :text
    add_column :statistics_announcements, :cancelled_at, :timestamp
    add_column :statistics_announcements, :cancelled_by_id, :integer

    add_index :statistics_announcements, :cancelled_by_id
  end
end
