class AddFeaturedServicesAndGuidance < ActiveRecord::Migration
  def up
    create_table :featured_services_and_guidance do |t|
      t.string :url
      t.string :title
      t.references :linkable
      t.string :linkable_type
      t.timestamps
    end
  end

  def down
    drop_table :featured_services_and_guidance
  end
end
