class CreateSyncCheckResults < ActiveRecord::Migration
  def change
    create_table :sync_check_results do |t|
      t.string :check_class
      t.integer :item_id
      t.text :failures

      t.timestamps null: false

      t.index %i[check_class item_id], unique: true
    end
  end
end
