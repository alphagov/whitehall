class AddFeaturedTopicsAndPoliciesList < ActiveRecord::Migration
  def change
    create_table :featured_topics_and_policies_lists do |t|
      t.integer :organisation_id, null: false
      t.text :summary
      t.boolean :link_to_filtered_policies, default: true, null: false
      t.timestamps
    end
    add_index :featured_topics_and_policies_lists, :organisation_id
  end
end
