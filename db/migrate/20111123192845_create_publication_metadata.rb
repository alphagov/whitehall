class CreatePublicationMetadata < ActiveRecord::Migration
  def change
    create_table :publication_metadata, force: true do |t|
      t.references :publication
      t.date :publication_date
      t.string :unique_reference
      t.string :isbn
      t.boolean :research, default: false
      t.string :order_url
      t.timestamps
    end
  end
end