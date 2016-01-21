class AddContentIdToStatisticsAnnouncements < ActiveRecord::Migration
  def change
    add_column :statistics_announcements, :content_id, :string, null: false
  end
end
