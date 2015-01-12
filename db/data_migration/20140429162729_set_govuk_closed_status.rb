def mark_organisation_as_replaced(organisation_name)
  agency = Organisation.find_by(name: organisation_name)
  agency.govuk_closed_status = 'replaced'
  agency.save
end

Organisation.closed.update_all(govuk_closed_status: 'no_longer_exists')
mark_organisation_as_replaced("Vehicle and Operator Services Agency")
mark_organisation_as_replaced("Driving Standards Agency")
mark_organisation_as_replaced("UK Border Agency")
