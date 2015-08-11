class LengthenChangeNoteOnStatisticsAnnouncementDates < ActiveRecord::Migration
  def up
    change_column(:statistics_announcement_dates, :change_note, :text)
  end

  def down
    change_column(:statistics_announcement_dates, :change_note, :string)
  end
end
