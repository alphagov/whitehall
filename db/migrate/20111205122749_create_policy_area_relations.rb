class CreatePolicyAreaRelations < ActiveRecord::Migration
  def change
    create_table :policy_area_relations, force: true do |t|
      t.integer :policy_area_id, null: false
      t.integer :related_policy_area_id, null: false
      t.timestamps
    end
  end
end