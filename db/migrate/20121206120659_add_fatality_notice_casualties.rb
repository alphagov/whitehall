class AddFatalityNoticeCasualties < ActiveRecord::Migration
  def change
    create_table :fatality_notice_casualties, force: true do |t|
      t.integer :fatality_notice_id
      t.text :personal_details
    end
  end
end
