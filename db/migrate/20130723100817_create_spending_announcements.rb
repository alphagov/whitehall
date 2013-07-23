class CreateSpendingAnnouncements < ActiveRecord::Migration
  def change
    create_table :spending_announcements do |t|
      t.belongs_to :organisation
      t.decimal :spending
      t.datetime :startdate
      t.datetime :enddate
      t.timestamps
    end
  end
end
