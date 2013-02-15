class CreateEditionWorldwideOffices < ActiveRecord::Migration
  def change
    create_table :edition_worldwide_offices do |t|
      t.references :edition
      t.references :worldwide_office

      t.timestamps
    end
    add_index :edition_worldwide_offices, :edition_id
    add_index :edition_worldwide_offices, :worldwide_office_id
  end
end
