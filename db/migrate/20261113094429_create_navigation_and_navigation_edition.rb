class CreateNavigationAndNavigationEdition < ActiveRecord::Migration[8.1]
  def change
    create_table :navigations do |t|
      t.string :content_id, null: false

      t.timestamps
    end

    add_index :navigations, :content_id, unique: true

    create_table :navigation_editions do |t|
      t.references :navigation, null: false, foreign_key: true
      t.references :edition, null: false, foreign_key: true, type: :integer, index: { unique: true }

      t.timestamps
    end
  end
end
