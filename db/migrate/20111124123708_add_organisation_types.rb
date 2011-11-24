class AddOrganisationTypes < ActiveRecord::Migration
  def change
    create_table :organisation_types, force: true do |t|
      t.string :name
      t.timestamps
    end
    add_column :organisations, :organisation_type_id, :integer
  end
end