WorldLocation.all.each do |location|
  location.update_column :analytics_identifier, WorldLocation.analytics_prefix + location.id.to_s
end
