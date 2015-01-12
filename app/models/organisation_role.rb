class OrganisationRole < ActiveRecord::Base
  belongs_to :organisation, inverse_of: :organisation_roles
  belongs_to :role, inverse_of: :organisation_roles

  validates :organisation, :role, presence: true
end
