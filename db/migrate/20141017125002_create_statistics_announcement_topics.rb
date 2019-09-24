class CreateStatisticsAnnouncementTopics < ActiveRecord::Migration
  def change
    create_table :statistics_announcement_topics, id: false do |t|
      t.references :statistics_announcement
      t.references :topic

      t.timestamps
    end

    add_index :statistics_announcement_topics, :statistics_announcement_id,
      name: "index_statistics_announcement_topics_on_statistics_announcement"

    add_index :statistics_announcement_topics, :topic_id
  end
end
