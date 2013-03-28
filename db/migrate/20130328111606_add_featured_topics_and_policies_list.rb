class AddFeaturedTopicsAndPoliciesList < ActiveRecord::Migration
  def change
    create_table :featured_topics_and_policies_lists do |t|
      t.integer :organisation_id, null: false
      t.text :summary
      t.timestamps
    end
  end
end
