class CreateOrganisationPolicyAreas < ActiveRecord::Migration
  def change
    create_table :organisation_policy_areas, force: true do |t|
      t.integer :organisation_id, null: false
      t.integer :policy_area_id, null: false
      t.timestamps
    end
  end
end