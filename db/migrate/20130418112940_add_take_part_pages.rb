class AddTakePartPages < ActiveRecord::Migration
  def change
    create_table :take_part_pages do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :summary, null: false
      t.text :body, limit: (16.megabytes - 1), null: false
      t.string :carrierwave_image
      t.string :image_alt_text
      t.integer :ordering, null: false
      t.timestamps
    end

    add_index :take_part_pages, :slug, unique: true
    add_index :take_part_pages, :ordering
  end
end
