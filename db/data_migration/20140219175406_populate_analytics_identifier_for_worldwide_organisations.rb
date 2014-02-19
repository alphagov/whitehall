WorldwideOrganisation.all.each do |organisation|
  organisation.update_column :analytics_identifier, WorldwideOrganisation.analytics_prefix + organisation.id.to_s
end
