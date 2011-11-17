class CreateOrganisationalRelationships < ActiveRecord::Migration
  def change
    create_table :organisational_relationships, force: true do |t|
      t.integer :parent_organisation_id
      t.integer :child_organisation_id
      t.timestamps
    end
    
    add_index :organisational_relationships, :parent_organisation_id
    add_index :organisational_relationships, :child_organisation_id
  end
end