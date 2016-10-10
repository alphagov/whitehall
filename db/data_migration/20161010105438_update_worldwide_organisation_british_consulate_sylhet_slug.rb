world_org = WorldwideOrganisation.find_by(slug: 'british-high-commission-office-sylhet')
world_org.slug = 'british-consulate-sylhet'
world_org.save!
