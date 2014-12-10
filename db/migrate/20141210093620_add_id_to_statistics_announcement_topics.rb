class AddIdToStatisticsAnnouncementTopics < ActiveRecord::Migration
  def change
    add_column :statistics_announcement_topics, :id, :primary_key
  end
end
