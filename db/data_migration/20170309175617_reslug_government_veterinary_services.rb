veterinary_services = Organisation.find_by(slug: "civil-service-government-veterinary-surgeons")

new_slug = "civil-service-government-veterinary-service"
DataHygiene::OrganisationReslugger.new(veterinary_services, new_slug).run!
