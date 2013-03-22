class CreateAccessAndOpeningTimes < ActiveRecord::Migration
  def change
    create_table :access_and_opening_times do |t|
      t.text :body
      t.string :accessible_type
      t.integer :accessible_id

      t.timestamps
    end
    add_index :access_and_opening_times, [:accessible_id, :accessible_type], name: 'accessible_index'
  end
end
