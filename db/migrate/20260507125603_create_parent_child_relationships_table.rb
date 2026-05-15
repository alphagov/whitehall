class CreateParentChildRelationshipsTable < ActiveRecord::Migration[8.1]
  def change
    create_table :parent_child_relationships do |t|
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

      t.timestamps
    end

    # strong_migrations prefers indexes outside create_table
    # rubocop:disable Rails/BulkChangeTable
    add_index :parent_child_relationships,
              %i[parent_edition_id child_document_id],
              unique: true,
              name: "idx_pcr_unique_parent_child"

    add_index :parent_child_relationships,
              %i[parent_edition_id ordering],
              name: "idx_pcr_parent_ordering"
    # rubocop:enable Rails/BulkChangeTable
  end
end
