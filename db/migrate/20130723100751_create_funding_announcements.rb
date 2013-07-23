class CreateFundingAnnouncements < ActiveRecord::Migration
  def change
    create_table :funding_announcements do |t|
      t.belongs_to :organisation
      t.decimal :funding
      t.datetime :startdate
      t.datetime :enddate
      t.timestamps
    end
  end
end
