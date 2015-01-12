service = WorldwideService.find_by(name: 'Marriage and Civil Partnership ceremonies')
service.name = 'Issue certificate of no impediment'
service.save!
