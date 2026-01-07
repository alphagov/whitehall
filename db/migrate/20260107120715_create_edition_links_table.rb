class CreateEditionLinksTable < ActiveRecord::Migration[8.0]
  def change
    create_table :edition_links do |t|
      t.references :edition, index: true, null: false
      t.references :document, index: true, null: false
      t.string :link_type, null: false
      t.timestamps
    end
  end
end
