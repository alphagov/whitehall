class CreateEditionEditionableWorldwideOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :edition_editionable_worldwide_organisations do |t|
      t.integer "edition_id"
      t.integer "document_id"

      t.timestamps

      t.index %w[edition_id], name: "index_edition_editionable_worldwide_organisations_on_edition_id"
      t.index %w[document_id], name: "index_edition_editionable_worldwide_organisations_on_document_id"
    end
  end
end
