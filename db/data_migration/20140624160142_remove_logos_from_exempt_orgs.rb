Organisation.where(govuk_status: "exempt").each do |organisation|
  @logger.info "Processing #{organisation.slug}"
  next unless organisation.organisation_logo_type == OrganisationLogoType::CustomLogo

  organisation.organisation_logo_type = OrganisationLogoType::NoIdentity
  organisation.remove_logo = true
  unless organisation.save
    @logger.warn "  Forcing save on invalid organisation #{organisation.slug}. Errors: #{organisation.errors.full_messages}"
    organisation.save!(validate: false)
  end
  @logger.info "  Removed logo from #{organisation.slug}"
end
