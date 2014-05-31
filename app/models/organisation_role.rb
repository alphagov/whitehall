class OrganisationRole < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :role

  validates :organisation_id, :role_id, presence: true
end
