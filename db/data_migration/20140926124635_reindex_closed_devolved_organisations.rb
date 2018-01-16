devolved_organisations = Organisation.where(govuk_status: 'closed', govuk_closed_status: 'devolved')
devolved_organisations.each(&:update_in_search_index)
