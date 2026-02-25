class CreateEditionDocumentRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :edition_relationships do |t|
      t.references :parent_edition,
                   null: false,
                   type: :integer,
                   foreign_key: { to_table: :editions },
                   index: true

      t.references :child_document,
                   null: false,
                   type: :integer,
                   foreign_key: { to_table: :documents },
                   index: true

      # only used for ordered relationships (e.g. manual sections)
      t.integer :position
      t.timestamps
    end

    # The strong_migrations gem enforces doing this outside of change_table.
    # rubocop:disable Rails/BulkChangeTable
    add_index :edition_relationships,
              %i[parent_edition_id child_document_id],
              unique: true,
              name: "idx_edrel_unique_parent_child_document"

    add_index :edition_relationships,
              %i[parent_edition_id position],
              name: "idx_edrel_parent_position"
    # rubocop:enable Rails/BulkChangeTable
  end
end
