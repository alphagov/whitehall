class CreateFeaturedPolicies < ActiveRecord::Migration
  def change
    create_table :featured_policies do |t|
      t.string :policy_content_id
      t.integer :ordering, null: false
      t.references :organisation
    end
  end
end
