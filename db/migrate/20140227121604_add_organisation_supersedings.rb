class AddOrganisationSupersedings < ActiveRecord::Migration
  def change
    create_table :organisation_supersedings do |t|
      t.integer :superseded_organisation_id
      t.integer :superseding_organisation_id
    end
    add_index :organisation_supersedings, :superseded_organisation_id
  end
end
