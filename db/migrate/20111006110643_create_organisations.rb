class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations, force: true do |t|
      t.string :name
      t.timestamps
    end

    create_table :edition_organisations, force: true do |t|
      t.integer :edition_id
      t.integer :organisation_id
      t.timestamps
    end
  end
end