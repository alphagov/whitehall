class CreateFeaturedLinks < ActiveRecord::Migration
  class FeaturedServicesAndGuidance < ActiveRecord::Base
  end
  class TopTasks < ActiveRecord::Base
  end

  def up
    create_table :featured_links  do |t|
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
      FeaturedLinks.create top_task.attributes
    end
    FeaturedServicesAndGuidance.all.each do |featured_link|
      FeaturedLinks.create featured_link.attributes
    end
  end

  def down
    drop_table :featured_links
  end
end
