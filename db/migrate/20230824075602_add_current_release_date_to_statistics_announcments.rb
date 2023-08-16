class AddCurrentReleaseDateToStatisticsAnnouncments < ActiveRecord::Migration[7.0]
  def change
    change_table :statistics_announcements, bulk: true do |t|
      fk_options = {
        to_table: :statistics_announcement_dates,
        on_delete: :nullify,
        on_update: :cascade,
      }

      t.references :current_release_date, foreign_key: fk_options, type: :integer
    end
  end
end
