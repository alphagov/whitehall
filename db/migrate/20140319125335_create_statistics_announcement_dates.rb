class CreateStatisticsAnnouncementDates < ActiveRecord::Migration
  def change
    create_table :statistics_announcement_dates do |t|
      t.references :statistics_announcement
      t.datetime   :release_date
      t.integer    :precision
      t.boolean    :confirmed
      t.string     :change_note

      t.timestamps
    end

    add_index :statistics_announcement_dates, [:statistics_announcement_id, :created_at], name: 'statistics_announcement_release_date'
  end
end
