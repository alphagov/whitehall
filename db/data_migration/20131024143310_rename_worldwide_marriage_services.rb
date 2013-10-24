documentary_services = WorldwideService.where(service_type_id: 2)
documentary_services.find_by_name("Marriage or Civil Partnership registrations").update_attribute(:name, "Registrations of Marriage and Civil Partnerships")
documentary_services.find_by_name("Marriages or Civil Partnership service").update_attribute(:name, "Marriage and Civil Partnership ceremonies")
