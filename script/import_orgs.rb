require "csv"

data = CSV.parse(File.open(Rails.root + "db/organisations.csv", "r:UTF-8"), headers: true)

other = OrganisationType.find_by_name("Other")

data.each do |org_data|
  if org_data["Sponsoring dept"] != "n/a"
    sponsoring_organisation = Organisation.find_by_name(org_data["Sponsoring dept"])
    unless sponsoring_organisation
      puts ">>> Creating temporary sponsoring organisation #{org_data["Sponsoring dept"]}"
      sponsoring_organisation = Organisation.create!(name: org_data["Sponsoring dept"], organisation_type: other)
    end
  else
    sponsoring_organisation = nil
  end

  type = OrganisationType.find_by_name!(org_data["Type"])
  organisation = Organisation.find_by_name(org_data["Name"])
  if organisation
    puts "Updating #{organisation.name}"
    organisation.organisation_type = type
    organisation.acronym = org_data["Shortname"]
    organisation.url = org_data["URL"]
    organisation.about_us = org_data["Description"] if organisation.about_us.blank?
    if sponsoring_organisation && !organisation.parent_organisations.include?(sponsoring_organisation)
      organisation.parent_organisations << sponsoring_organisation
    end
    organisation.save!
  else
    puts "Creating #{org_data["Name"]}"
    Organisation.create!(
      name: org_data["Name"],
      organisation_type: type,
      acronym: org_data["Shortname"],
      url: org_data["URL"],
      about_us: org_data["Description"],
      parent_organisations: [sponsoring_organisation].compact
    )
  end
end
