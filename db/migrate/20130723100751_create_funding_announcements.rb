class CreateFundingAnnouncements < ActiveRecord::Migration
  def change
    create_table :funding_announcements do |t|
      t.belongs_to :organisation
      t.decimal :funding
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
