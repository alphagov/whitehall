# Force new proper slugs to be generated
module Slugging
  def should_generate_new_friendly_id?
    true
  end
end

%w{michael-anderson paul-waring vicki-treadell paul-madden mandie-campbell}.each do |slug|
  if role = Role.find_by_slug(slug)
    role.save!
    puts "Role #{role.name} updated"
  end
end
