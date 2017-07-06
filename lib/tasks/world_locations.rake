namespace :world_locations do
  task redirect_world_location_translations_to_en: :environment do
    world_location_ids = WorldLocation.all.pluck(:id)

    world_location_ids.each do |world_location_id|
      WorldLocationRedirectWorker.perform_async(world_location_id)
    end
  end
end
