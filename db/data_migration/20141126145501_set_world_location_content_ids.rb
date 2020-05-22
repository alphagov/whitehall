WorldLocations.where(content_id: nil).find_each do |world_location|
  world_location.update(content_id: SecureRandom.uuid)
end
