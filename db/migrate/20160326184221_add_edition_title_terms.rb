class AddEditionTitleTerms < ActiveRecord::Migration
  def change
    create_table :edition_title_terms, id: false do |t|
      t.integer :edition_id
      t.string :term

      t.index :edition_id
      t.index :term
    end
  end
end
