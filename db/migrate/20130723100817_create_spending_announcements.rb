class CreateSpendingAnnouncements < ActiveRecord::Migration
  def change
    create_table :spending_announcements do |t|
      t.belongs_to :organisation
      t.decimal :spending
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
