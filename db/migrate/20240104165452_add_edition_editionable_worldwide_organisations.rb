class AddEditionEditionableWorldwideOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :edition_editionable_worldwide_organisations do |t|
      t.integer :worldwide_organisation_id
      t.integer :edition_id

      t.timestamps
    end
  end
end
