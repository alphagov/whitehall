all_worldwide_orgs = WorldwideOrganisation.all

all_worldwide_orgs.each do |worldwide_org|
  worldwide_org.save
end
