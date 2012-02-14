task :set_active_flags => :environment do |t|
  Organisation.all.each do |organisation|
    organisation.update_cached_active_state!
  end
end
