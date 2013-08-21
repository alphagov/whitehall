module Whitehall
  module Uploader
    module Finders
      autoload :MinisterialRolesFinder, 'whitehall/uploader/finders/ministerial_roles_finder'
      autoload :NewsArticleTypeFinder, 'whitehall/uploader/finders/news_article_type_finder'
      autoload :OperationalFieldFinder, 'whitehall/uploader/finders/operational_field_finder'
      autoload :OrganisationFinder, 'whitehall/uploader/finders/organisation_finder'
      autoload :PoliciesFinder, 'whitehall/uploader/finders/policies_finder'
      autoload :PublicationTypeFinder, 'whitehall/uploader/finders/publication_type_finder'
      autoload :RoleAppointmentsFinder, 'whitehall/uploader/finders/role_appointments_finder'
      autoload :SluggedModelFinder, 'whitehall/uploader/finders/slugged_model_finder'
      autoload :SpeachTypeFinder, 'whitehall/uploader/finders/speech_type_finder'
      autoload :WorldLocationsFinder, 'whitehall/uploader/finders/world_locations_finder'
    end
  end
end
