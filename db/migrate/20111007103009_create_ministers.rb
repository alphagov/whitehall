class CreateMinisters < ActiveRecord::Migration
  def change
    create_table :ministers, force: true do |t|
      t.string :name
      t.timestamps
    end
    create_table :edition_ministers, force: true do |t|
      t.references :edition
      t.references :minister
      t.timestamps
    end
  end
end