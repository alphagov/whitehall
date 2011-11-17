class OrganisationalRelationship < ActiveRecord::Base
  belongs_to :parent_organisation, class_name: "Organisation"
  belongs_to :child_organisation, class_name: "Organisation"
end