class CreateFeaturedLinks < ActiveRecord::Migration
  class FeaturedServicesAndGuidance < ApplicationRecord
    self.table_name = :featured_services_and_guidance
  end
  class TopTasks < ApplicationRecord
  end

  def up
    create_table :featured_links do |t|
      t.string :url
      t.string :title
      t.references :linkable
      t.string :linkable_type
      t.timestamps
    end

    orgs_with_featured_services_and_guidance = FeaturedServicesAndGuidance.where("linkable_type='Organisation'").group('linkable_id').map { |link| link.linkable_id }

    TopTasks.all.each do |top_task|
      if top_task.linkable_type == 'Organisation' && orgs_with_featured_services_and_guidance.include?(top_task.linkable_id)
        next
      end
      FeaturedLink.create top_task.attributes
    end
    FeaturedServicesAndGuidance.all.each do |featured_link|
      FeaturedLink.create featured_link.attributes
    end
  end

  def down
    drop_table :featured_links
  end
end
