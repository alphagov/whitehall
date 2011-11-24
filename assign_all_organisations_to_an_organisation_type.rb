organisation_type = OrganisationType.find_by_name!("Ministerial department")

Organisation.find_each do |organisation|
  organisation.organisation_type = organisation_type
  organisation.save!
end