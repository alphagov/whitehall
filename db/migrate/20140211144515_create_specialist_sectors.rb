class CreateSpecialistSectors < ActiveRecord::Migration
  def change
    create_table :specialist_sectors do |t|
      t.references :edition
      t.string :tag

      t.timestamps
    end

    add_index :specialist_sectors, [:edition_id, :tag], unique: true
  end
end
