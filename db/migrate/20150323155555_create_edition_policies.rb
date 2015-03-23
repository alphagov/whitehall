class CreateEditionPolicies < ActiveRecord::Migration
  def change
    create_table :edition_policies do |t|
      t.references :edition
      t.string :policy_content_id
      t.timestamps
    end

    add_index :edition_policies, :edition_id
    add_index :edition_policies, :policy_content_id
  end
end
