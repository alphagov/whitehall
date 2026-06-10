editions_with_org_access_limits = Edition.unscoped.where(access_limiting: "organisations")

puts "Found #{editions_with_org_access_limits.count} editions with access limiting set to 'organisations'"

warnings = []
errors = []

editions_with_org_access_limits.each do |edition|
  # CorporateInformationPages don't have leading or supporting orgs
  next if edition.instance_of?(CorporateInformationPage)

  msg = "Edition #{edition.id}, lead org ids #{edition.lead_organisations.pluck(:id)}, supporting org ids: #{edition.supporting_organisations.pluck(:id)}"

  orgs = [edition.lead_organisations, edition.supporting_organisations].flatten.compact

  if orgs.empty?
    warnings << "Edition #{edition.id} has `access_limiting` set to orgs but has no lead or supporting orgs"
  end

  access_limiting_orgs = []

  orgs.each do |limiting_org|
    access_limiting_org = AccessLimitingOrganisation.new(edition:, organisation: limiting_org)

    if access_limiting_org.save
      access_limiting_orgs << access_limiting_org
    else
      errors << "Edition #{edition.id} cannot save new `AccessLimitingOrganisation` #{limiting_org.name}`: #{access_limiting_org.errors.full_messages.to_sentence}"
    end
  end

  edition.access_limiting_organisations = access_limiting_orgs

  if edition.save(validate: false)
    msg += " - access limiting orgs successfully updated to: #{edition.access_limiting_organisations.pluck(:organisation_id)}"
  else
    errors << "Edition #{edition.id} failed to update: #{edition.errors.full_messages.to_sentence}"
  end

  puts msg
end

puts "Completed with #{warnings.size} warnings and #{errors.size} errors:"
warnings.each { |warning| puts "WARNING: #{warning}" }
errors.each { |error| puts "ERROR: #{error}" }
