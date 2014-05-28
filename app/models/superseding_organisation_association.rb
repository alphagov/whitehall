class SupersedingOrganisationAssociation < ActiveRecord::Base
  self.table_name = "organisation_supersedings"
  belongs_to :superseding_organisation, class_name: "Organisation", foreign_key: "superseding_organisation_id"
  belongs_to :superseded_organisation, class_name: "Organisation", foreign_key: "superseded_organisation_id"
end
