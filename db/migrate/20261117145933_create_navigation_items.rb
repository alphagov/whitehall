class CreateNavigationItems < ActiveRecord::Migration[8.1]
  def change
    create_table :navigation_items do |t|
      t.references :navigation_edition, null: false, foreign_key: true
      t.references :child_document, null: false, foreign_key: { to_table: :documents }, type: :integer

      t.timestamps
    end
  end
end
