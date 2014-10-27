class DropFeaturedServicesAndGuidanceAndTopTasks < ActiveRecord::Migration
  def up
    drop_table :featured_services_and_guidance
    drop_table :top_tasks
  end
end
