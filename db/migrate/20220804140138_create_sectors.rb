class CreateSectors < ActiveRecord::Migration[7.0]
  def change
    create_table :sectors do |t|
      t.integer :parent_sector_id, index: true
      t.text :title
      t.timestamps
    end
  end
end
