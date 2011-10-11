class OrganisationMinisterialRole < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :ministerial_role
end