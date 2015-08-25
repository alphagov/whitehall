class AddStateToStatisticsAnnouncement < ActiveRecord::Migration
  def change
    add_column :statistics_announcements, :publishing_state, :string, default: "published", null: false
    add_column :statistics_announcements, :redirect_url, :string
  end
end
