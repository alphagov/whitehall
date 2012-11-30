module Whitehall
  module Uploader
    module Finders
      autoload :OrganisationFinder, 'whitehall/uploader/finders/organisation_finder'
      autoload :PoliciesFinder, 'whitehall/uploader/finders/policies_finder'
      autoload :RoleAppointmentsFinder, 'whitehall/uploader/finders/role_appointments_finder'
      autoload :DocumentSeriesFinder, 'whitehall/uploader/finders/document_series_finder'
      autoload :CountriesFinder, 'whitehall/uploader/finders/countries_finder'
    end
  end
end
