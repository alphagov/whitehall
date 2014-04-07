class AddCreatorIdToStatisticsAnnouncementDates < ActiveRecord::Migration
  def change
    add_column :statistics_announcement_dates, :creator_id, :integer
    add_index  :statistics_announcement_dates, :creator_id
  end
end
