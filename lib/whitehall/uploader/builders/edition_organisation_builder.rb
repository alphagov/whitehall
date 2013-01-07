require 'whitehall/uploader/builders'

class Whitehall::Uploader::Builders::EditionOrganisationBuilder
  def self.build_lead(organisation, ordering = 1)
    return nil if organisation.nil?
    EditionOrganisation.new(organisation: organisation, lead: true, lead_ordering: ordering)
  end
end
